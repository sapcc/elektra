EmailService::Engine.routes.draw do

  get '/' => 'web#index', as: :index

  resources :settings, only: [:index, :show]
  # resources :settings do
  #   member do 
  #     post :enable, :disable
  #   end
  # end

  resources :templated_emails, only: [:index, :new, :create]
  resources :emails, only: [:index, :show, :new, :create, :destroy]
  resources :templates , only: [:index, :show, :new, :edit, :create, :destroy, :update]
  resources :configsets, only: [:index, :show, :new, :edit, :create, :destroy, :update]
  resources :verifications, only: [:index, :show, :new, :create, :destroy]
  resources :domain_verifications
  resources :stats, only: [:index]

  post 'verify_dkim', action: :verify_dkim, controller: 'domain_verifications'
  post 'activate_dkim', action: :activate_dkim, controller: 'domain_verifications'
  post 'deactivate_dkim', action: :deactivate_dkim, controller: 'domain_verifications'

  # get '/emails/info' => 'emails#info'
  # get 'settings/show_config' => 'settings#show_config'
  # get 'settings' => 'settings#index'
  # post 'settings/enable_cronus' => 'settings#enable_cronus'
  # post 'settings/disable_cronus' => 'settings#disable_cronus'
  
end
