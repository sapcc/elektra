Networking::Engine.routes.draw do
  resources :floating_ips
  resources :security_groups

  resources :routers do
    get 'topology'
    get 'node_details'
  end

  namespace :networks do
    %i(external private).each do |type|
      resources type do
        resources :access
      end
    end
  end
end
