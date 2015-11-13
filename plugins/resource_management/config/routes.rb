ResourceManagement::Engine.routes.draw do
  get '/' => 'application#index'

  get 'resources'          => 'application#index'
  get 'resources/compute'  => 'application#compute'
  get 'resources/network'  => 'application#network'
  get 'resources/storage'  => 'application#storage'
  get 'resources/details'  => 'application#details'
  get 'resources/request'  => 'application#resource_request'

  get 'resources/admin'    => 'admin#index'
#  get 'resources/compute'  => 'application#compute'
#  get 'resources/network'  => 'application#network'
#  get 'resources/storage'  => 'application#storage'
#  get 'resources/details'  => 'application#details'
#  get 'resources/request'  => 'application#resource_request'


end
