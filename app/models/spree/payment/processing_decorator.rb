module Spree::Payment::ProcessingDecorator
  def cancel!
    if payment_method.is_a? Spree::Gateway::Payu
      cancel_with_payu
    else
      super
    end
  end

  private

  def cancel_with_payu
    response = payment_method.cancel(id)
    handle_response(response, :void, :failure)
  end
end

Spree::Payment.include(Spree::Payment::ProcessingDecorator)
