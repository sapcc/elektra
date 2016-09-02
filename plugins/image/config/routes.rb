Image::Engine.routes.draw do
  namespace :os_images do
    resources :public do
      put :unpublish
    end
    
    resources :private do
      put :publish
      resources :members, module: :private, except: [:edit, :update, :show]
    end
    resources :suggested do
      put :accept
      put :reject
    end
  end
end
