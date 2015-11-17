Automation::Engine.routes.draw do

  resources :instances, only: [:index, :show] do
    get 'show_section', :on => :collection
  end

end