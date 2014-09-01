Gaintegration::Application.routes.draw do
  root 'stores#index'
  resources :stores, except: [:show]
  resources :metrics, only: [:show]
  resources :user_events, only: [:show]
  resource :visits, only: [:show]

  get :status, to: 'application#status'

  post 'sender/send_transaction' => 'sender#send_transaction'
  post 'sender/send_event' => 'sender#send_event'
end
