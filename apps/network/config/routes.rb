Network::Engine.routes.draw do
  scope "/:domain_id" do
    scope "/:project_id" do
      resources :networks
    end
  end
end
