Image::Engine.routes.draw do
  root to: 'application#index'

  # next generation plugin
  namespace :ng do
    get '/', to: 'images#app'
    resources :images, except: %i[new edit] do
      put 'update_visibility'

      resources :members, except: %i[show new edit] do
        put 'accept', on: :collection
        put 'reject', on: :collection
      end
    end
  end

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
