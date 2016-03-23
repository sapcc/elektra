ResourceManagement::Engine.routes.draw do
  scope '/', as: 'resources' do
    get  '/' => 'project_resources#index'
    get  ':area',  to: 'project_resources#show_area', constraints: { area: /(?:compute|network|storage)/ }, as: 'area'
    get  'request'  => 'project_resources#new_request', as: 'new_request'
    post 'request'  => 'project_resources#create_request', as: 'create_request'
    get  'sync_now' => 'project_resources#sync_now'
  end

  scope 'admin', as: 'admin' do
    get  '/'        => 'domain_admin#index'
    get  ':area',  to: 'domain_admin#show_area', constraints: { area: /(?:compute|network|storage)/ }, as: 'area'
    get  'details'  => 'domain_admin#details'
    get  'request'  => 'domain_admin#new_request',    as: 'new_request'
    post 'request'  => 'domain_admin#create_request', as: 'create_request'
    get  'sync_now' => 'domain_admin#sync_now'
    get  'edit'     => 'domain_admin#edit'
    get  'update'   => 'domain_admin#update'
    get  'cancel'   => 'domain_admin#cancel'
    get  'review_request'  => 'domain_admin#review_request'
    post 'approve_request' => 'domain_admin#approve_request'
    get  'default_quota/:id' => 'domain_admin#edit_default_quota', as: 'edit_default_quota'
    put  'default_quota/:id' => 'domain_admin#update_default_quota', as: 'update_default_quota'
  end

  scope 'cloud_admin', as: 'cloud_admin' do
    get  '/'               => 'cloud_admin#index'
    get  ':area',         to: 'cloud_admin#show_area', constraints: { area: /(?:compute|network|storage)/ }, as: 'area'
    get  'details'         => 'cloud_admin#details'
    get  'request'         => 'cloud_admin#resource_request'
    get  'sync_now'        => 'cloud_admin#sync_now'
    get  'edit'            => 'cloud_admin#edit'
    get  'update'          => 'cloud_admin#update'
    get  'cancel'          => 'cloud_admin#cancel'
    get  'review_request'  => 'cloud_admin#review_request'
    post 'approve_request' => 'cloud_admin#approve_request'

    get 'capacity/:id' => 'cloud_admin#edit_capacity',   as: 'edit_capacity'
    put 'capacity/:id' => 'cloud_admin#update_capacity', as: 'update_capacity'
  end
 
end
