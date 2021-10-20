DnsService::Engine.routes.draw do
  get "request-zone-wizard" => 'request_zone_wizard#new', as: :new_zone_request
  post "request-zone-wizard" => 'request_zone_wizard#create', as: :create_zone_request

  get "create-zone-wizard" => 'create_zone_wizard#new'
  post "create-zone-wizard" => 'create_zone_wizard#create'

  resources :zones do
    scope module: :zones do
      resources :recordsets
      resources :shared_zones, only: [:index,:new,:create,:destroy]
      resources :transfer_requests, only: [:new,:create]

      collection do
        resources :transfer_requests, only: [:index,:destroy] do
          put 'accept', on: :member
        end
      end
    end
  end
end
