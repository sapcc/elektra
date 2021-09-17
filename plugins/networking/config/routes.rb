Networking::Engine.routes.draw do
  root to: 'networks#index'
  resources :floating_ips
  resources :ports, except: %i[edit new] do
    get 'widget', on: :collection
    get 'networks', on: :collection
    get 'subnets', on: :collection
    get 'security_groups', on: :collection
  end

  resources :security_groups, except: %i[edit new], path: 'security-groups' do
    get 'widget', on: :collection
    resources :rules, module: :security_groups
    resources :rbacs, module: :security_groups, only: %i[index create destroy]
  end

  resources :routers do
    get 'topology'
    get 'node_details'
  end

  scope :asr do
    get 'routers/:router_id' => 'asr#show_router', as: :asr_router
    put 'routers/:router_id' => 'asr#sync_router', as: :asr_sync_router

    get '/configs/:router_id' => 'asr#show_config', as: :asr_config
    get '/statistics/:router_id' => 'asr#show_statistics', as: :asr_statistics
  end

  resources :backup_networks, only: %i[index new create]
  resources :network_wizard, only: %i[new create]
    
  scope :network_wizard do
    get  'skip_wizard' => 'network_wizard#skip_wizard_confirm'
    post 'skip_wizard' => 'network_wizard#skip_wizard'
  end


  resources :network_usage_stats, only: %i[index]

  namespace :networks do
    %i[external private].each do |type|
      resources type do
        resources :access
        resources :dhcp_agents
      end
    end

    scope ':network_id' do
      get 'ip_availability'
      get 'manage_subnets'
      resources :subnets, only: %i[index create destroy]
    end
  end
end
