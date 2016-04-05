Automation::Engine.routes.draw do

  resources :agents, only: [:index, :show] do
    get 'index_update', :on => :collection
    get 'install', :on => :collection
    post 'show_instructions', :on => :collection
    get 'run_automation', :on => :collection

    resources :jobs, only: [:index, :show] do
      get 'show_payload', to: 'jobs#show_data', defaults: { attr: 'payload' }
      get 'show_log', to: 'jobs#show_data', defaults: { attr: 'log' }
    end
  end

  resources :automations, only: [:index, :new, :create, :show]

  resources :runs, only: [:show] do
    get ':id/show_log/', to: 'runs#show_log', :on => :collection, as: 'show_payload'
  end

end