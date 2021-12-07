Galvani::Engine.routes.draw do
  root to: 'application#galvani_widget'
  resources :tags, only: [:index, :create, :destroy] do
    collection do
      get 'config' => 'tags#profiles_config'
    end
  end
end
