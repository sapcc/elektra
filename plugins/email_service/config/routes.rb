EmailService::Engine.routes.draw do
  # get '/' => 'application#index', as: :index 
  # get '/' => 'emails#index', as: :index
  root 'emails#index', as: :index
  get '/info' => 'emails#info'

  get 'settings' => 'settings#index'
  post 'settings/enable_cronus' => 'settings#enable_cronus'
  post 'settings/disable_cronus' => 'settings#disable_cronus'
  
  get 'settings/new_configset' => 'settings#new_configset'
  post 'settings/create_configset' => 'settings#create_configset'
  post 'settings/destroy_configset' => 'settings#destroy_configset'
  # resource :settings, only: [:index]
  resource :templated_emails, only: [:index, :new, :create]

  resources :emails, only: [:index, :show, :new, :create, :destroy]
  resources :templates # , only: [:index, :show, :new, :create, :destroy]
  resources :verifications, only: [:index, :show, :new, :create, :destroy]
end
