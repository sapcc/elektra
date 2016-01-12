Identity::Engine.routes.draw do
  resources :domains, only: [:index]
  
  resources :projects, only:[:index]

  namespace :projects  do

    get 'web-console' 

    scope :wizard do
      get 'request' => 'request_wizard#new'
      post 'request' => 'request_wizard#create'
      get 'create' => 'create_wizard#new'
      post 'create' => 'create_wizard#create'
    end
  end

  get 'project/home' => 'projects#show', as: :project
  get 'home' => 'domains#show', as: :domain

  resources :credentials
end
