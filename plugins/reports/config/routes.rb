Reports::Engine.routes.draw do
  resources :cost, controller: "cost", only: %i[] do
    get "project", on: :collection
    get "domain", on: :collection
  end
end
