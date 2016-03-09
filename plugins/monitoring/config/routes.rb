Monitoring::Engine.routes.draw do
  get '/' => 'application#index', as: :entry
end
