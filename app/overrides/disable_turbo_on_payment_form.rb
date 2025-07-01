# frozen_string_literal: true

class DisableTurboOnPaymentForm
  Deface::Override.new(
    virtual_path: 'spree/checkout/_payment',
    name: 'disable_turbo_on_payment_form',
    replace: "erb[loud]:contains('form_for @order')",
    text: <<-ERB
    <%= form_for @order, url: spree.update_checkout_path(@order.token, @order.state), html: { id: "checkout_form_\#{@order.state}" }, data: { turbo: false } do |form| %>
    ERB
  )
end