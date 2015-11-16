Automation::Engine.routes.draw do
  get '/instances' => 'instances#index'
end