EmailService::Engine.routes.draw do
  get '/' => 'application#index', as: :index
  get '/info' => 'emails#info'
  # get '/verifications/verify_email' => 'verifications#verify_email'
  # get '/verifications/new' => 'verifications#new'
  resources :emails, only: [:index, :show, :new, :create, :destroy]
  resources :templates, only: [:index, :show, :new, :create, :destroy]
  resources :verifications, only: [:index, :show, :new, :create, :destroy]
  # get '/' => 'emails#index', as: :index
end
