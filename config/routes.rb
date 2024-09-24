Spree::Core::Engine.routes.draw do
  post '/payu/comeback/:gateway_id/:order_id' => 'payu#comeback', :as => :payu_comeback
end
