Metrics::Engine.routes.draw do
  get '/' => 'application#index', as: :index
  get '/maia' => 'application#maia', as: :maia
  get '/grafana' => 'application#gaas', as: :gaas
end
