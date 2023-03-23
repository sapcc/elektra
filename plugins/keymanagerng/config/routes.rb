Keymanagerng::Engine.routes.draw do
  root to: 'application#show', as: :root

  get "/username", to: 'application#user_name', via: :all

  get '/*path', to: 'application#show', via: :all
end

