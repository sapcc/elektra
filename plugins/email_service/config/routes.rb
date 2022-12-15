EmailService::Engine.routes.draw do
  get "/" => "emails#index", :as => :index
  resources :plain_emails, only: %i[new create edit]
  resources :templated_emails, only: %i[new create edit]
  resources :emails, only: [:index]
  resources :templates, only: %i[index show new edit create destroy update]
  resources :configsets, only: %i[index show new edit create destroy update]
  resources :email_verifications, only: %i[index show new create destroy]
  resources :stats, only: [:index]
  resources :domain_verifications, only: %i[index show new create destroy] do
    member do
      post "verify_dkim"
      post "activate_dkim"
      post "deactivate_dkim"
    end
  end
  resources :settings, only: %i[index destroy] do
    member do
      post "enable_cronus"
      post "disable_cronus"
    end
  end

  resources :custom_verification_email_templates,
            only: %i[index show new edit create destroy update]

  resources :multicloud_accounts, only: %i[index show new edit create destroy]

  resources :ec2_credentials, only: %i[index create show] do
    member { delete :destroy }
  end

  # test helper methods with the hidden route
  # get '/web' => 'web#index', as: :web
  get "/web/test" => "web#test", :as => :test
end
