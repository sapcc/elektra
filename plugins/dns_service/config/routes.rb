DnsService::Engine.routes.draw do
  resources :zones do
    resources :recordsets, module: :zones
  end
end
