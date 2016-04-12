Automation::Engine.routes.draw do

  resources :nodes, only: [:index, :show] do
    get 'index_update', :on => :collection
    get 'install', :on => :collection
    post 'show_instructions', :on => :collection
    get 'run_automation', :on => :collection
  end

  resources :jobs, only: [:index, :show] do
    get ':id/show_payload', to: 'jobs#show_data', defaults: { attr: 'payload' }, :on => :collection, as: 'show_payload'
    get ':id/show_log', to: 'jobs#show_data', defaults: { attr: 'log' }, :on => :collection, as: 'show_log'
  end

  resources :automations, only: [:index, :new, :create, :show, :edit, :update, :destroy]

  resources :runs, only: [:show] do
    get ':id/show_log/', to: 'runs#show_log', :on => :collection, as: 'show_payload'
  end

end