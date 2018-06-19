Identity::Engine.routes.draw do
  root to: 'application#index'

  resources :domains, only: [:index]
  resources :groups do
    get 'members/new' => 'groups#new_member'
    post 'members' => 'groups#add_member'
    delete 'members/:id' => 'groups#remove_member', as: :members_remove
  end

  namespace :domains do
    scope :wizard do
      get 'create_project' => 'create_wizard#new'
      post 'create_project' => 'create_wizard#create'
    end

    resources :users, only: [:index, :show] do
      put 'enable' => 'users#enable'
      put 'disable' => 'users#disable'
    end
  end

  resources :projects, only: [:index] do
    delete '/' => 'projects#destroy', on: :member, as: :delete
  end

  resources :roles, only: [:index]

  get 'user-projects' => 'projects#user_projects'

  namespace :projects do
    # start page which renders react components
    get '/role-assignments' => 'role_assignments#index', constraints: { format: :html }
    #### PROJECT ROLE ASSIGNMENTS ####
    # do not use project_id! This would overwrite global project_id parameter
    scope '/:scope_project_id', constraints: { format: :json } do
      resources :role_assignments, only: %i[index]
      resource :role_assignments, only: %i[update]
    end
    ##### END #####

    get 'web-console'
    get 'api-endpoints'
    get 'download-openrc'

    scope :wizard do
      get 'request_project' => 'request_wizard#new'
      post 'request_project' => 'request_wizard#create'
    end

    resources :members, only: [:index, :new, :create] do
      put '/' => 'members#update', on: :collection
    end
    #
    # resources :groups, only: [:index, :new, :create] do
    #   put '/' => 'groups#update', on: :collection
    #   get 'members' => 'groups#members', as: :members
    # end
    #
    # # global role assignments (cloud admin)
    # namespace :cloud_admin do
    #   resources :project_members, only: [:index, :new, :create] do
    #     put '/' => 'project_members#update', on: :collection
    #   end
    #   resources :project_groups, only: [:index, :new, :create] do
    #     put '/' => 'project_groups#update', on: :collection
    #   end
    # end
  end

  get 'project/home' => 'projects#show', as: :project
  get 'project/view' => 'projects#view', as: :project_view
  get 'project/wizard' => 'projects#show_wizard', as: :project_wizard
  get 'project/edit' => 'projects#edit', as: :edit_project
  put 'project' => 'projects#update', as: :update_project
  get 'home' => 'domains#show', as: :domain

  resources :credentials

end
