ResourceManagement::Engine.routes.draw do

  scope '/', as: 'resources' do
    get  '/' => 'project_resources#index'
    get  'area/:area',  to: 'project_resources#show_area', as: 'area'
    get  'request'  => 'project_resources#new_request', as: 'new_request'
    post 'request'  => 'project_resources#create_request', as: 'create_request'
    get  'confirm_reduce_quota' => 'project_resources#confirm_reduce_quota'
    post 'reduce_quota' => 'project_resources#reduce_quota'
    get  'sync_now' => 'project_resources#sync_now'
    get  'request-package'          => 'project_resources#new_package_request', as: 'new_package_request'
    post 'request-package/:package' => 'project_resources#create_package_request', as: 'create_package_request'
    post  'save_settings' => 'project_resources#save_settings'
    get  'settings' => 'project_resources#settings'
    get  'skip_wizard' => 'project_resources#skip_wizard_confirm'
    post 'skip_wizard' => 'project_resources#skip_wizard'
  end

  scope 'admin', as: 'admin' do
    get  '/'        => 'domain_admin#index'
    get  'area/:area',  to: 'domain_admin#show_area', as: 'area'
    get  'details'  => 'domain_admin#details'
    get  'request'  => 'domain_admin#new_request',    as: 'new_request'
    post 'request'  => 'domain_admin#create_request', as: 'create_request'
    get  'edit'     => 'domain_admin#edit'
    get  'update'   => 'domain_admin#update'
    get  'cancel'   => 'domain_admin#cancel'
    get  'review_request'  => 'domain_admin#review_request'
    post 'approve_request' => 'domain_admin#approve_request'
    get  'review_package_request'  => 'domain_admin#review_package_request'
    post 'approve_package_request' => 'domain_admin#approve_package_request'
    post 'reduce_quota' => 'domain_admin#reduce_quota'
    get  'confirm_reduce_quota' => 'domain_admin#confirm_reduce_quota'
  end

  scope 'cloud_admin', as: 'cloud_admin' do
    get  '/'               => 'cloud_admin#index'
    get  'area/:area',         to: 'cloud_admin#show_area', as: 'area'
    get  'details'         => 'cloud_admin#details'
    get  'request'         => 'cloud_admin#resource_request'
    get  'edit'            => 'cloud_admin#edit'
    get  'update'          => 'cloud_admin#update'
    get  'cancel'          => 'cloud_admin#cancel'
    get  'review_request'  => 'cloud_admin#review_request'
    post 'approve_request' => 'cloud_admin#approve_request'

    get 'capacity' => 'cloud_admin#edit_capacity',   as: 'edit_capacity'
    put 'capacity' => 'cloud_admin#update_capacity', as: 'update_capacity'

    get 'inconsistencies' => 'cloud_admin#check_inconsistencies', as: 'inconsistencies'
  end

  scope 'automation', as: 'automation' do
    get 'dump_data'   => 'automation#dump_data'
  end

end
