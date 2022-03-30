EmailService::Engine.routes.draw do
  # get '/' => 'web#index', as: :index
  get '/' => 'emails#index', as: :index
  resources :plain_emails, only: [:new, :create, :edit]
  resources :templated_emails, only: [:new, :create, :edit]
  resources :emails, only: [:index ]
  resources :templates, only: [:index, :show, :new, :edit, :create, :destroy, :update]
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
  resources :settings, only: [:index, :destroy] do 
    member do 
      post 'enable_cronus'
      post 'disable_cronus'
    end
  end

  resources :custom_verification_email_templates, only: [:index, :show, :new, :edit, :create, :destroy, :update]

  resources :multicloud_accounts, only: [:index, :show, :new, :edit, :create, :destroy]
  resources :ec2_credentials, only: [:index, :create, :show] do 
    member do 
      delete :destroy
    end
  end

end
