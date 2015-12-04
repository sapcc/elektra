ResourceManagement::Engine.routes.draw do
  scope '/', as: 'resources' do
    get '/' => 'project_resources#index'
    get ':area',  to: 'project_resources#show_area', constraints: { area: /(?:compute|network|storage)/ }, as: 'area'
    get 'details'  => 'project_resources#details'
    get 'request'  => 'project_resources#resource_request'
    get 'sync_now' => 'project_resources#sync_now'
  end

  scope 'admin', as: 'admin' do
    get '/'        => 'domain_admin#index'
    get ':area',  to: 'domain_admin#show_area', constraints: { area: /(?:compute|network|storage)/ }, as: 'area'
    get 'details'  => 'domain_admin#details'
    get 'request'  => 'domain_admin#resource_request'
  end

  # this is only for demo, I have no idea where I can put the cloudadmin views
  scope 'cloud_admin', as: 'cloud_admin' do
    get '/'        => 'cloud_admin#index'
    get ':area',  to: 'cloud_admin#show_area', constraints: { area: /(?:compute|network|storage)/ }, as: 'area'
    get 'details'  => 'cloud_admin#details'
    get 'request'  => 'cloud_admin#resource_request'
  end
 
  # TODO: remove (or move into cloud admin scope)
  get 'manual_sync' => 'project_resources#manual_sync'

end
