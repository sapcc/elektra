Keymanagerng::Engine.routes.draw do
  root to: 'application#show', as: :root

  scope '/keymanagerng-api' do
    resources :entries, only: %i[index create update destroy] 
  end

  get '/*path', to: 'application#show', via: :all
end

