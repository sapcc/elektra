EmailService::Engine.routes.draw do
  # get '/' => 'application#index', as: :index 
  # get '/' => 'emails#index', as: :index
  root 'emails#index', as: :index

  get '/info' => 'emails#info'

  get 'emails/stats' => 'emails#stats'
  
  get 'settings/show_config' => 'settings#show_config'
  get 'settings' => 'settings#index'
  post 'settings/enable_cronus' => 'settings#enable_cronus'
  post 'settings/disable_cronus' => 'settings#disable_cronus'
  
  get 'configset' => 'configset#index'
  get 'configset/new_configset' => 'configset#new_configset'
  get 'configset/show_configset' => 'configset#show_configset'

  post 'configset/create_configset' => 'configset#create_configset'
  post 'configset/destroy_configset' => 'configset#destroy_configset'


  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end
  
  resources :configset, concerns: :paginatable

  resource :templated_emails, only: [:index, :new, :create]
  resources :emails, only: [:index, :show, :new, :create, :destroy]

  resources :templates do
    member do
      post :modify
    end
  end

 
  resources :verifications, only: [:index, :show, :new, :create, :destroy]

  # resources :email_verifications, only: [:index, :show, :new, :create, :destroy]
  resources :domain_verifications #, only: [:index, :show, :new, :create, :destroy]

  post 'verify_dkim', action: :verify_dkim, controller: 'domain_verifications'
  post 'activate_dkim', action: :activate_dkim, controller: 'domain_verifications'
  post 'deactivate_dkim', action: :deactivate_dkim, controller: 'domain_verifications'

end