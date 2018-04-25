Cloudops::Engine.routes.draw do
  root to: 'application#show', as: :start

  resources :entries, only: %i[index create update destroy]
  resources :objects, only: %i[index show] do
    collection do
      get 'types'
    end
  end
end
