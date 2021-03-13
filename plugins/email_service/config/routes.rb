EmailService::Engine.routes.draw do
  get '/' => 'application#index', as: :index
  resources :emails, only: [:index, :show, :new, :create, :destroy]
  resources :templates, only: [:index, :show, :new, :create, :destroy]
  # get '/' => 'emails#index', as: :index
end
