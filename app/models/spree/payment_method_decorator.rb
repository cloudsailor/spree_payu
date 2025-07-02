# frozen_string_literal: true

module Spree
  module PaymentMethodDecorator
    def self.prepended(base)
      base.preference :payment_method_type, :string
      base.preference :delivery_method_ids, :string
      base.preference :image_url, :string
    end
  end
end

::Spree::PaymentMethod.prepend(Spree::PaymentMethodDecorator)
