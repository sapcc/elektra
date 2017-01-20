DnsService::Engine.routes.draw do
  resources :zones do
    scope module: :zones do
      resources :recordsets
      resources :transfer_requests, only: [:new,:create]

      collection do
        resources :transfer_requests, only: [:index,:destroy] do
          put 'accept', on: :member
        end
      end
    end
  end
end
