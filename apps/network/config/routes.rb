Network::Engine.routes.draw do
  scope "/:domain_id/:project_id" do
      resources :networks
  end
end
