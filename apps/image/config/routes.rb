Image::Engine.routes.draw do
  scope "/:domain_id/:project_id" do
    resources :os_images
  end 
end
