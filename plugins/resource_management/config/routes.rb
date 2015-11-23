ResourceManagement::Engine.routes.draw do
  scope '/', as: 'resources' do
    get '/' => 'application#index'
    get ':area',  to: 'application#show_area', constraints: { area: /(?:compute|network|storage)/ }, as: 'area'
    get 'details'  => 'application#details'
    get 'request'  => 'application#resource_request'
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
 
  get 'manual_sync' => 'application#manual_sync'

end
