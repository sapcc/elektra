Automation::Engine.routes.draw do

  resources :agents, only: [:index, :show] do
    get 'index_update', :on => :collection
    get 'install', :on => :collection
    post 'show_instructions', :on => :collection
    get 'show_log', :on => :collection

    resources :jobs, only: [:index, :show] do
      get 'show_payload', to: 'jobs#show_data', defaults: { attr: 'payload' }
      get 'show_log', to: 'jobs#show_data', defaults: { attr: 'log' }
    end
  end

  resources :automations, only: [:index, :new, :create, :show]

end