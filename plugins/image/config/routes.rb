Image::Engine.routes.draw do
  namespace :os_images do
    resources :public
    resources :private do
      resources :members, module: :private, except: [:edit, :update, :show]
      # get :new_member
      # post :add_member
      # delete :delete_member, on: :collection
      # delete 'member/:member_id', to: '#show'
      
    end
    resources :suggested do
      put :accept
      put :reject
    end
  end
end
