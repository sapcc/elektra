Image::Engine.routes.draw do
  namespace :os_images, module: :os_images do
    resources :public
    resources :private
  end
end
