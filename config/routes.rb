Gaintegration::Application.routes.draw do
  root 'stores#index'
  resources :stores, except: [:show] do
    resources :metrics, only: [:show]
  end

  get :status, to: 'application#status'

  post 'sender/send_transaction' => 'sender#send_transaction'
  post 'sender/send_event' => 'sender#send_event'
end
