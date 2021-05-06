EmailService::Engine.routes.draw do
  # get '/' => 'application#index', as: :index 
  # get '/' => 'emails#index', as: :index
  root 'emails#index', as: :index



  get '/info' => 'emails#info'

  get 'emails/stats' => 'emails#stats'
  get 'settings' => 'settings#index'
  post 'settings/enable_cronus' => 'settings#enable_cronus'
  post 'settings/disable_cronus' => 'settings#disable_cronus'
  
  get 'configset' => 'configset#index'
  get 'configset/new_configset' => 'configset#new_configset'
  get 'configset/show_configset' => 'configset#show_configset'

  post 'configset/create_configset' => 'configset#create_configset'
  post 'configset/destroy_configset' => 'configset#destroy_configset'

  resource :templated_emails, only: [:index, :new, :create]
  resources :emails, only: [:index, :show, :new, :create, :destroy]
  resources :templates # , only: [:index, :show, :new, :create, :destroy]
  resources :verifications, only: [:index, :show, :new, :create, :destroy]


end
