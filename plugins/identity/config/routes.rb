Identity::Engine.routes.draw do

  resources :domains, only: [:index]
  namespace :domains do
    scope :wizard do
      get 'request_project' => 'request_wizard#new'
      post 'request_project' => 'request_wizard#create'
      get 'create_project' => 'create_wizard#new'
      post 'create_project' => 'create_wizard#create'
    end
  end

  resources :projects, only: [:index] do
    delete '/' => 'projects#destroy', on: :member, as: :delete
  end

  get 'user-projects' => 'projects#user_projects'

  namespace :projects do

    get 'web-console'
    get 'api-endpoints'
    
    
    resources :members, only: [:index, :new, :create] do
      put '/' => 'members#update', on: :collection
    end
    
    resources :groups, only: [:index, :new, :create] do
      put '/' => 'groups#update'
    end
  end

  get 'project/home' => 'projects#show', as: :project
  get 'project/edit' => 'projects#edit', as: :edit_project
  put 'project' => 'projects#update', as: :update_project
  get 'home' => 'domains#show', as: :domain

  resources :credentials

end
