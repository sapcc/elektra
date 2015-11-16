ResourceManagement::Engine.routes.draw do
  get '/' => 'application#index'

  get 'resources'          => 'application#index'
  get 'resources/compute'  => 'application#compute'
  get 'resources/network'  => 'application#network'
  get 'resources/storage'  => 'application#storage'
  get 'resources/details'  => 'application#details'
  get 'resources/request'  => 'application#resource_request'

  get '/'        => 'application#index'
  get 'compute'  => 'application#compute'
  get 'network'  => 'application#network'
  get 'storage'  => 'application#storage'
  get 'request'  => 'application#resource_request'

  get 'admin'          => 'domain_admin#index'
  get 'admin/compute'  => 'domain_admin#compute'
  get 'admin/network'  => 'domain_admin#network'
  get 'admin/storage'  => 'domain_admin#storage'
  get 'admin/details'  => 'domain_admin#details'
  get 'admin/request'  => 'domain_admin#resource_request'

end
