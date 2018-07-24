Networking::Engine.routes.draw do
  root to: 'networks#index'
  resources :floating_ips
  resources :ports, except: %i[edit new] do
    get 'widget', on: :collection
    get 'networks', on: :collection
    get 'subnets', on: :collection
    get 'security_groups', on: :collection
  end

  resources :security_groups, except: %i[edit update] do
    resources :rules, module: :security_groups
  end

  resources :routers do
    get 'topology'
    get 'node_details'
  end

  resources :backup_networks, only: %i[index new create]
  resources :network_wizard, only: %i[new create]

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
