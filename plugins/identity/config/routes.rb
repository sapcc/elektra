Identity::Engine.routes.draw do
  resources :domains, only: [:index]
  
  resources :projects, only:[:index] do
    delete '/' => 'projects#destroy', on: :member, as: :delete
  end 

  namespace :projects  do

    get 'web-console' 

    scope :wizard do
      get 'request' => 'request_wizard#new'
      post 'request' => 'request_wizard#create'
      get 'create' => 'create_wizard#new'
      post 'create' => 'create_wizard#create'
    end
    
    resources :members, only: [:index,:new, :create] do
      put '/' => 'members#update', on: :collection
    end
  end

  get 'project/home' => 'projects#show', as: :project
  get 'project/edit' => 'projects#edit', as: :edit_project
  put 'project' => 'projects#update', as: :update_project
  get 'home' => 'domains#show', as: :domain

  resources :credentials
end
