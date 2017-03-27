Lookup::Engine.routes.draw do
  root to: 'os_objects#index'
  put 'show_object' => 'os_objects#show_object'
  match '/instances/:query' => 'os_objects#show_instance', as: :instances, via: [:get, :post]
  match '/projects/:query' => 'os_objects#show_project', as: :projects, via: [:get, :post]
  match '/networks/:network_type/:query' => 'os_objects#show_network', as: :networks, via: [:get, :post]
end
