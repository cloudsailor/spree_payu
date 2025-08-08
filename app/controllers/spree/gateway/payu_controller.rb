module Spree
  class Gateway::PayuController < Spree::BaseController
    skip_before_action :verify_authenticity_token, only: :comeback
    include Spree::Core::ControllerHelpers::Order

    def comeback
      payu_order_id = params.dig(:order, :orderId)

      return head :unprocessable_entity if payu_order_id.nil?

      payment = Spree::Payment.find_by("public_metadata->>'token' = ?", payu_order_id)

      if payment.nil?
        Rails.logger.error "Payment not found for order: #{payu_order_id}"
        head :unprocessable_entity
      end

payment.public_metadata['pay_method'] ||= payment.payment_method.fetch_transaction_pay_method(payu_order_id)


      if payment.state == 'checkout' &&
        payment.payment_method.verify_transaction(params[:order][:status],
                                                 payment,
                                                 params[:order][:totalAmount],
                                                 params[:order][:currencyCode],
                                                  payu_order_id) && payment.order.update_with_updater!

        head :ok
      end
    end
  end
end
