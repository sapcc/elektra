Compute::Engine.routes.draw do
  resources :instances, except: [:edit, :update] do
    member do
      get 'console'
      get 'update_item'
      get 'new_floatingip'
      get 'new_size'
      get 'new_snapshot'
      put 'resize'
      put 'create_image'
      put 'confirm_resize'
      put 'revert_resize'
      put 'stop'
      put 'start'
      put 'pause'
      put 'suspend'
      put 'resume'
      put 'reboot'
      put 'attach_floatingip'
      delete 'detach_floatingip'
    end
  end

  resources :keypairs
  
  resources :flavors, except: [:show] do
    resources :members, module: :flavors, except: [:edit, :update, :show]
  end
end
