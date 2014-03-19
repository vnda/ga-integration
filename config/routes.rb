Gaintegration::Application.routes.draw do
  resources :stores

  post 'sender/send_transaction' => 'sender#send_transaction'
  root 'stores#index'
end
