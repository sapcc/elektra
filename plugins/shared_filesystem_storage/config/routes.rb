# frozen_string_literal: true

SharedFilesystemStorage::Engine.routes.draw do
  root to: 'application#show', as: :start

  resources :shares, except: %i[new edit], constraints: { format: :json } do
    resources :rules, module: 'shares', except: %i[show new edit update]
    get :availability_zones, constraints: { format: :json }, on: :collection
    member do
      get :export_locations, constraints: { format: :json }
      put :size, to: 'shares#update_size'

      put 'reset-status' => 'shares#reset_status'
      delete 'force-delete' => 'shares#force_delete'
    end
  end
  resources :snapshots, except: %i[new edit], constraints: { format: :json }
  resources :error_messages, only: %i[index], constraints: { format: :json }

  resources :share_types, only: %i[index], constraints: { format: :json }

  namespace :cloud_admin do
    resources :pools, only: %i[index show]
  end

  resources :security_services, except: %i[show new edit],
                                constraints: { format: :json },
                                path: 'security-services'

  resources :share_networks, except: %i[show new edit],
                             constraints: { format: :json },
                             path: 'share-networks' do
    resources :security_services, module: 'share_networks',
                                  except: %i[show new edit update],
                                  path: 'security-services'
    get :networks, constraints: { format: :json }, on: :collection
    get :subnets, constraints: { format: :json }, on: :collection

    get :share_servers, constraints: { format: :json }, on: :member,
                        path: 'share-servers'
  end
end
