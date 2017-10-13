Metrics::Engine.routes.draw do
  get '/' => 'application#index', as: :index
  get 'maia' => 'application#maia', as: :maia
end
