Automation::Engine.routes.draw do

  resources :agents, only: [:index, :show] do
    get 'index_update', :on => :collection
    get 'install', :on => :collection
    post 'show_instructions', :on => :collection
    get 'show_log', :on => :collection
  end

end