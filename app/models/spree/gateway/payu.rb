require 'faraday'
require 'bigdecimal'
require 'countries'

module Spree
  class Gateway::Payu < PaymentMethod
    class GatewayPayuError < StandardError; end

    preference :payu_client_id, :string
    preference :payu_pos_id, :string
    preference :payu_second_key, :string
    preference :payu_pay_methods_type, :string
    preference :payu_pay_methods_value, :string
    preference :payu_second_key, :string
    preference :payu_client_secret, :string
    preference :test_mode, :boolean, default: false
    preference :return_url, :string, default: "http://localhost:3000"
    preference :return_status_url, :string, default: "http://localhost:3000"
    preference :max_payment_amount, :integer
    preference :min_payment_amount, :integer

    def payment_profiles_supported?
      false
    end

    def source_required?
      false
    end

    def available_for_order?(order)
      return false if preferred_min_payment_amount.present? && order.total <= preferred_min_payment_amount
      return false if preferred_max_payment_amount.present? && order.total >= preferred_max_payment_amount

      true
    end

    def cancel(order_id, *args)
      Rails.logger.debug("Starting cancellation for #{order_id}")

      Rails.logger.debug("Spree order #{order_id} has been canceled.")
      ActiveMerchant::Billing::Response.new(true, 'Spree order has been canceled.')
    end

    def amount(amount)
      (BigDecimal(amount.to_s) * BigDecimal('100')).to_i.to_s
    end

    def credit(credit_cents, payment_id, options)
      order = options[:originator].try(:payment).try(:order)
      payment = options[:originator].try(:payment)
      reimbursement = options[:originator].try(:reimbursement)
      order_number = order.try(:number)
      order_currency = order.try(:currency)

      ActiveMerchant::Billing::Response.new(true, 'Refund successful')
    end

    def order_url
      if preferred_test_mode
        'https://secure.snd.payu.com/api/v2_1/orders'
      else
        'https://secure.payu.com/api/v2_1/orders'
      end
    end

    def register_order(order, payment_id, gateway_id)
      return if order.blank? || payment_id.blank? || gateway_id.blank?

      payment = order.payments.find payment_id

      conn = Faraday.new(url: order_url) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.request :authorization, 'Bearer', authorize
      end

      response = conn.post do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = register_order_payload(order, payment, gateway_id).to_json
      end

      if (200..303).include? response.status
        response_body = JSON.parse(response.body)
        Rails.logger.debug("create order - #{response.inspect}")
        payment.update(public_metadata: { token: response_body['orderId'], payment_url: (response_body['redirectUri']+ "&lang=#{order.billing_address.country.iso.downcase}") })
      else
        raise GatewayPayuError, "register_order #{order.id}, payment_id: #{payment_id} failed => #{response.inspect}"
      end
    rescue GatewayPayuError => e
      Sentry.capture_exception(e)
      nil
    end

    def register_order_payload(order, payment, gateway_id)
      ip_address = order.last_ip_address || Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
      payload = {
                  customerIp: ip_address,
                  merchantPosId: preferred_payu_pos_id,
                  description: order.number,
                  currencyCode: order.currency,
                  totalAmount: amount(order.total),
                  products: items_payload(order.line_items),
                  continueUrl: "#{preferred_return_url}/orders/#{order.number}",
                  notifyUrl: "#{preferred_return_status_url}/gateway/payu/comeback/#{gateway_id}/#{order.id}",
                  extOrderId: "#{order.number}|#{payment.number}",
                  buyer: {
                    email: order.email,
                    phone: order.billing_address.phone,
                    firstName: order.billing_address.firstname,
                    lastName: order.billing_address.lastname,
                    language: language(order.billing_address.country.iso),
                    delivery: {
                      street: order.shipping_address.address1,
                      postalCode: order.shipping_address.zipcode,
                      city: order.shipping_address.city,
                      countryCode: order.shipping_address.country.iso
                    }
                  }
                }
      if preferred_payu_pay_methods_type.present? && preferred_payu_pay_methods_value.present?
        pay_methods = {
          payMethods: {
            payMethod: {
              type: preferred_payu_pay_methods_type,
              value: preferred_payu_pay_methods_value,
              amount: amount(order.total)
            }
          }
        }
        payload.merge!(pay_methods)
      end
      payload
    end

    def items_payload(line_items)
      line_items.map do |item|
        {
          quantity: item.quantity,
          unitPrice: amount(item.price),
          name: item.name
        }
      end
    end

    def authorize_url
      if preferred_test_mode
        'https://secure.snd.payu.com/pl/standard/user/oauth/authorize'
      else
        'https://secure.payu.com/pl/standard/user/oauth/authorize'
      end
    end

    def authorize
      # https://developers.payu.com/europe/api#tag/Authorize/operation/oauth
      conn = Faraday.new(url: authorize_url) do |faraday|
        faraday.adapter Faraday.default_adapter
      end

      authorize_payload = {
        grant_type: 'client_credentials',
        client_id: preferred_payu_client_id&.to_i,
        client_secret: preferred_payu_client_secret
      }

      response = conn.post do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(authorize_payload)
      end

      if response.success?
        response_body = JSON.parse(response.body)
        response_body['access_token']
      else
        raise GatewayPayuError, "Token: #{response.inspect}"
      end
    rescue GatewayPayuError => e
      Sentry.capture_exception(e)
    end

    def verify_url(payu_order_id)
      if preferred_test_mode
        "https://secure.snd.payu.com/api/v2_1/orders/#{payu_order_id}/captures"
      else
        "https://secure.payu.com/api/v2_1/orders/#{payu_order_id}/captures"
      end
    end

    def verify_transaction(status, payment, amount, currency, payu_order_id)
      return false if status.blank? || payment.blank? || amount.blank? || currency.blank? || payu_order_id.blank?
      return true if status == 'PENDING'
      return false if !['WAITING_FOR_CONFIRMATION', 'COMPLETED', 'CANCELED'].include?(status)

      float_amount = (amount.to_f / 100).to_f

      if status == 'WAITING_FOR_CONFIRMATION'
        conn = Faraday.new(url: verify_url(payu_order_id)) do |faraday|
          faraday.adapter Faraday.default_adapter
          faraday.request :authorization, 'Bearer', authorize
        end

        response = conn.post do |req|
          req.headers['Content-Type'] = 'application/json'
        end

        if response.success?
          return true
        else
          raise GatewayPayuError, "Verify_transaction #{payment.order.id} failed => #{response.inspect}"
        end
      end

      if payment.can_complete? && status == 'COMPLETED'
        payment.amount = float_amount
        payment.complete
      elsif status == 'CANCELED'
        payment.cancel!
      end

      private_metadata = payment.private_metadata
      private_metadata[:order_id] = payu_order_id
      private_metadata[:currency] = currency
      private_metadata[:amount] = amount
      payment.update(private_metadata: private_metadata)
      true
    rescue GatewayPayuError => e
      Sentry.capture_exception(e)
      false
    end

    def transactions_url(payu_order_id)
      if preferred_test_mode
        "https://secure.snd.payu.com/api/v2_1/orders/#{payu_order_id}/transactions"
      else
        "https://secure.payu.com/api/v2_1/orders/#{payu_order_id}/transactions"
      end
    end

    def fetch_transaction_pay_method(payu_order_id)
      conn = Faraday.new(url: transactions_url(payu_order_id)) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.request :authorization, 'Bearer', authorize
      end

      response = conn.get do |req|
        req.headers['Content-Type'] = 'application/json'
      end
      pay_method_code = JSON.parse(response.body).dig("transactions", -1, 'payMethod', 'value')
      payment_flow = JSON.parse(response.body).dig("transactions", -1, 'paymentFlow')

      pay_method_name = ::MethodMapperService.name_for(pay_method_code, payment_flow)

      if response.success?
        pay_method_name.presence
      else
        raise GatewayPayuError, "Fetch transaction pay method for #{payu_order_id.id} failed => #{response.inspect}"
      end
    rescue GatewayPayuError => e
      Sentry.capture_exception(e)
    end

    def language(country_iso)
      country = ISO3166::Country.new(country_iso)
      country&.languages&.first || 'en'
    end

    def actions
      %w[capture void]
    end

    def can_capture?(payment)
      %w[checkout pending].include?(payment.state)
    end

    def can_void?(payment)
      payment.state != 'void'
    end

    def capture(*)
      simulated_successful_billing_response
    end

    def void(*)
      simulated_successful_billing_response
    end

    private

    def simulated_successful_billing_response
      ActiveMerchant::Billing::Response.new(true, '', {}, {})
    end
  end
end
