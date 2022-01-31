EmailService::Engine.routes.draw do
  get '/' => 'web#index', as: :index
  resources :settings, only: [:index, :show]
  resources :plain_emails, only: [:new, :create, :edit]
  resources :templated_emails, only: [:new, :create, :edit]
  resources :emails, only: [:index ]
  resources :templates , only: [:index, :show, :new, :edit, :create, :destroy, :update]
  resources :configsets, only: [:index, :show, :new, :edit, :create, :destroy, :update]
  resources :email_verifications, only: [:index, :show, :new, :create, :destroy]
  resources :stats, only: [:index]
  resources :domain_verifications, only: [:index, :show, :new, :create, :destroy] do
    member do 
      post 'verify_dkim'
      post 'activate_dkim'
      post 'deactivate_dkim'
    end
  end
end
