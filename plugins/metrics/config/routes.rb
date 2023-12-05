Metrics::Engine.routes.draw do
  get "/" => "application#index", :as => :index
end
