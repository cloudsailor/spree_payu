Spree::Core::Engine.add_routes do
  namespace :gateway do
    post '/payu/comeback/:gateway_id/:order_id' => 'payu#comeback', :as => :payu_comeback
    post '/payu_installment/comeback/:gateway_id/:order_id' => 'payu_installment#comeback', :as => :payu_installment_comeback
    post '/paypo/comeback/:gateway_id/:order_id' => 'paypo#comeback', :as => :paypo_comeback
  end
end
