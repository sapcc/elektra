EmailService::Engine.routes.draw do
  get '/' => 'application#index', as: :index
  get '/info' => 'emails#info'
  resources :emails do
    get 'emails/verify_email' => 'emails#verify_email'
  end
  resources :emails, only: [:index, :show, :new, :create, :destroy]
  resources :templates, only: [:index, :show, :new, :create, :destroy]
  # get '/' => 'emails#index', as: :index
end
