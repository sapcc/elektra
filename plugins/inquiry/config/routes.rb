Inquiry::Engine.routes.draw do
  scope "/:domain_id/(:project_id)" do
    resources :inquiries
  end
end
