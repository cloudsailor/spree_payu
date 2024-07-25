module Spree
  class Gateway::PayuController < Spree::BaseController
    skip_before_action :verify_authenticity_token, only: :comeback
    include Spree::Core::ControllerHelpers::Order

    def comeback
      payment = Spree::Payment.find_by("public_metadata->>'token' = ?", params[:order][:orderId])

      if payment&.state == 'checkout' &&
         payment.payment_method.verify_transaction(params[:order][:status],
                                                   payment,
                                                   params[:order][:totalAmount],
                                                   params[:order][:currencyCode],
                                                   params[:order][:orderId]) &&
          payment.order.update_with_updater!
        head :ok
      else
        head :unprocessable_entity
      end
    end
  end
end
