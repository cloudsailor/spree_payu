Spree::Core::Engine.add_routes do
  namespace :gateway do
    post '/payu/comeback/:gateway_id/:order_id' => 'payu#comeback', :as => :payu_comeback
    post '/payu_raty/comeback/:gateway_id/:order_id' => 'payu_raty#comeback', :as => :payu_raty_comeback
  end
end
