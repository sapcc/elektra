Inquiry::Engine.routes.draw do
  scope "/:domain_id/(:project_id)/inquiries" do
    get '/' => 'application#index'
  end
end
