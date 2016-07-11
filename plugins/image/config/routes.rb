Image::Engine.routes.draw do
  namespace :os_images do
    resources :public
    resources :shared
    resources :private do
      get :access_control
    end
  end
end
