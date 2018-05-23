Cloudops::Engine.routes.draw do
  root to: 'application#show', as: :start

  resources :role_assignments, only: %i[index create update destroy] do
    collection do
      get 'available_roles'
    end
  end

  resources :search, only: %i[index show] do
    collection do
      get 'types'
      get 'projects'
    end
  end
end
