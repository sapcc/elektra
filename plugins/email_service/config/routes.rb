EmailService::Engine.routes.draw do
  get '/' => 'web#index', as: :index
  resources :settings, only: [:index, :show]
  resources :templated_emails, only: [:index, :new, :create, :edit]
  resources :emails, only: [:index, :new, :create, :edit]
  resources :templates , only: [:index, :show, :new, :edit, :create, :destroy, :update]
  resources :configsets, only: [:index, :show, :new, :edit, :create, :destroy, :update]
  resources :verifications, only: [:index, :show, :new, :create, :destroy]
  resources :domain_verifications
  resources :stats, only: [:index]
  post 'verify_dkim', action: :verify_dkim, controller: 'domain_verifications'
  post 'activate_dkim', action: :activate_dkim, controller: 'domain_verifications'
  post 'deactivate_dkim', action: :deactivate_dkim, controller: 'domain_verifications'
end
