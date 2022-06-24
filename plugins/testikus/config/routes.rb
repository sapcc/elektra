Testikus::Engine.routes.draw do
  root to: 'application#show', as: :start

  resources :entries, only: %i[index create update destroy] 
end
