Metrics::Engine.routes.draw do
  get "/" => "application#index", :as => :index
  get "/grafana" => "application#gaas", :as => :gaas
end
