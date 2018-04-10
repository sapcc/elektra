Lookup::Engine.routes.draw do
  root to: 'os_objects#index'
  put 'show_object' => 'os_objects#show_object'
  # these routes allow to simply replace a link a customer gives you, with a lookup:
  # e.g. with https://dashboard.eu-de-1.cloud.sap/<domain>/<project>/networking/networks/private/<uuid>
  # you can lookup https://dashboard.eu-de-1.cloud.sap/ccadmin/cloud_admin/lookup/networks/private/<uuid>
  match '/instances/:query' => 'os_objects#show_instance', as: :instances, via: [:get, :post]
  match '/projects/:query' => 'os_objects#show_project', as: :projects, via: [:get, :post]
  match '/networks/private/:query' => 'os_objects#show_network_private', as: :private_networks, via: [:get, :post]
  match '/networks/external/:query' => 'os_objects#show_network_external', as: :external_networks, via: [:get, :post]

  get '/object/:object_type/:object_id' => 'services#find', as: :find_object
  get '/object/types' => 'services#object_types'

  get 'reverselookup/index' => 'reverse_lookup#index'
  post 'reverselookup/search' => 'reverse_lookup#search'
  get 'reverselookup/object_info/:reverseLookupObjectId' => 'reverse_lookup#object_info'
  get 'reverselookup/project/:reverseLookupProjectId' => 'reverse_lookup#project'
  get 'reverselookup/domain/:reverseLookupProjectId' => 'reverse_lookup#domain'
  get 'reverselookup/parents/:reverseLookupProjectId' => 'reverse_lookup#parents'
  get 'reverselookup/users/:reverseLookupProjectId' => 'reverse_lookup#users'
  get 'reverselookup/groups/:reverseLookupProjectId' => 'reverse_lookup#groups'
  get 'reverselookup/group_members/:reverseLookupGrouptId' => 'reverse_lookup#group_members'
end
