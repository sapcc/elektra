Cloudops::Engine.routes.draw do
  root to: 'application#show', as: :start

  resources :role_assignments, only: %i[index] do
    collection do
      get 'available_roles'
    end
  end

  resource :role_assignments, only: %i[update]
end
