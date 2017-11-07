%{PLUGIN_NAME}::Engine.routes.draw do
  get '/' => 'application#index'
  get '/entries' => 'application#entries'
  post '/entries' => 'application#create'
  update '/entries/:id' => 'application#update'
  delete '/entries/:id' => 'application#destroy'
end
