Spree::Core::Engine.add_routes do
  namespace :gateway do
    post '/payu/comeback/:gateway_id/:order_id' => 'payu#comeback', :as => :payu_comeback
  end
end
