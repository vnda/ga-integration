Gaintegration::Application.routes.draw do
  resources :stores

  post 'sender/send_transaction' => 'sender#send_transaction'
  post 'sender/send_event' => 'sender#send_event'
  root 'stores#index'
end
