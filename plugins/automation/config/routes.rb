Automation::Engine.routes.draw do
  get '/instances' => 'instances#index'
  get '/instances/show_section' => 'instances#show_section'
end