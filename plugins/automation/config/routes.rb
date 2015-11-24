Automation::Engine.routes.draw do

  resources :instances, only: [:index, :show] do
    get 'install_agent', :on => :collection
    get 'show_log', :on => :collection
    get 'show_section', :on => :collection
  end

end