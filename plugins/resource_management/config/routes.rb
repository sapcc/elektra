ResourceManagement::Engine.routes.draw do
  get '/' => 'application#index'

  # maybe we can remove resources here?
  get 'resources'          => 'application#index'
  get 'resources/:area',  to: 'application#show_area', constraints: { area: /(?:compute|network|storage)/ }, as: 'resources_area'
  get 'resources/details'  => 'application#details'
  get 'resources/request'  => 'application#resource_request'

  get 'admin'          => 'domain_admin#index'
  get 'admin/:area',  to: 'domain_admin#show_area', constraints: { area: /(?:compute|network|storage)/ }, as: 'admin_area'
  get 'admin/details'  => 'domain_admin#details'
  get 'admin/request'  => 'domain_admin#resource_request'

  # this is only for demo, I have no idea where I can put the cloudadmin views
  get 'cloud_admin'          => 'cloud_admin#index'
  get 'cloud_admin/:area',  to: 'cloud_admin#show_area', constraints: { area: /(?:compute|network|storage)/ }, as: 'cloud_admin_area'
  get 'cloud_admin/details'  => 'cloud_admin#details'
  get 'cloud_admin/request'  => 'cloud_admin#resource_request'
 
  get 'manual_sync' => 'application#manual_sync'

end
