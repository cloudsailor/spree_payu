# frozen_string_literal: true

module Spree
  module CheckoutControllerDecorator
    def update
      @previous_state = @order.state

      if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
        track_checkout_entered_email
        track_payment_info_entered
        track_checkout_step_completed

        unless params[:do_not_advance]
          @order.temporary_address = !params[:save_user_address]
          unless @order.next
            return if @order.address? && @order.line_items_without_shipping_rates.any? && turbo_stream_request?

            flash[:error] = @order.errors.messages.values.flatten.join("\n")
            redirect_to(spree.checkout_state_path(@order.token, @order.state)) && return
          end

          redirect_after_checkout_update(@order)
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def redirect_after_checkout_update(order)
      if order.completed?
        track_checkout_completed

        if payu_redirect?(order)
          redirect_to order.payments.last.public_metadata['payment_url'], allow_other_host: true, status: :see_other
        else
          redirect_to spree.checkout_complete_path(order.token), status: :see_other
        end
      else
        redirect_to spree.checkout_state_path(order.token, order.state)
      end
    end

    def payu_redirect?(order)
      payment = order.payments.last
      return false if payment.nil?

      url = payment.public_metadata&.[]('payment_url')
      url.present?
    end
  end
  end
end

if ::Spree::CheckoutController
   .included_modules.exclude?(Spree::CheckoutControllerDecorator)
  ::Spree::CheckoutController.prepend Spree::CheckoutControllerDecorator
end
