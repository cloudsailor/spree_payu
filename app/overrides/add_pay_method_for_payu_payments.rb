class AddPayMethodForPayuPayments
  Deface::Override.new(
    virtual_path: 'spree/admin/payments/_payment',
    name: 'add_payu_pay_method_to_admin_payment',
    insert_after: "erb[loud]:contains('link_to payment.payment_method.name')",
    text: <<~ERB
      <% if payment.payment_method.type == 'Spree::Gateway::Payu'  %> 
        <p class="mb-0 text-muted">
          <%= I18n.t('payu.pay_method')+': ' %>
          <strong><%= payment.public_metadata.fetch('pay_method', 'Unknown') %></strong>
        </p>
      <% end %>
    ERB
  )
end
