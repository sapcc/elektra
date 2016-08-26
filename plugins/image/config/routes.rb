Image::Engine.routes.draw do
  namespace :os_images do
    resources :public
    resources :private do
      get :access_control
      get :new_member
      post :add_member
    end
    resources :suggested do
      put :accept
      put :reject
    end
  end
end
