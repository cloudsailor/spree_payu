# frozen_string_literal: true

module Spree
  module PaymentMethodDecorator
    def self.prepended(base)
      base.preference :payment_method_type, :string
      base.preference :delivery_method_ids, :string
      base.preference :image_url, :string
    end

    def available_for_order?(order)
      !below_min_payment_amount?(order) &&
        !above_max_payment_amount?(order) &&
        available_for_shipment_method?(order.shipments)
    end

    def available_for_shipment_method?(shipments)
      shipping_method_ids ||= shipments.map { |shipment| shipment.shipping_method.id }.join(',')

      preferred_delivery_method_ids.include?(shipping_method_ids)
    end
  end
end

::Spree::PaymentMethod.prepend(Spree::PaymentMethodDecorator)
