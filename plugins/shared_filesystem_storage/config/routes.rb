SharedFilesystemStorage::Engine.routes.draw do
  root to: 'application#index', as: :start
  #get '/', to: 'application#index', as: :start, constraints: { format: :html }

  
  resources :shares, except: [:show,:new,:edit], constraints: { format: :json } do
    resources :rules, module: 'shares', except: [:show,:new,:edit,:update]
    get :availability_zones, constraints: { format: :json }, on: :collection
    #get :share_types, constraints: { format: :json }, on: :collection
  end
  resources :snapshots, except: [:show,:new,:edit], constraints: { format: :json }
  resources :share_networks, except: [:show,:new,:edit], constraints: { format: :json }, path: 'share-networks' do
    get :networks, constraints: { format: :json }, on: :collection
    get :subnets, constraints: { format: :json }, on: :collection
  end
end
