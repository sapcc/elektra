Automation::Engine.routes.draw do

  resources :instances, only: [:index, :show] do
    get 'index_update', :on => :collection
    get 'install_agent', :on => :collection
    post 'show_instructions', :on => :collection
    get 'show_log', :on => :collection
  end

end