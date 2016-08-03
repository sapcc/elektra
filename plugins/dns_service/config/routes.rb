DnsService::Engine.routes.draw do
  get '/' => 'application#index', as: :entry
  
  resources :zones do
    resources :recordsets, module: :zones
  end
end
