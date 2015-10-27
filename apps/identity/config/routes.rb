Identity::Engine.routes.draw do
  scope "/:domain_id" do
    scope "/:project_id" do
      resources :credentials
      resources :projects
    end
  end
end
