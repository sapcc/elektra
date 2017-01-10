Compute::Engine.routes.draw do
  resources :instances, except: [:edit, :update] do
    member do
      get 'console'
      get 'update_item'
      get 'new_floatingip'
      get 'new_size'
      get 'new_snapshot'
      get 'attach_interface'
      get 'detach_interface'
      put 'create_interface'
      put 'delete_interface'
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
    resources :metadata, module: :flavors, except: [:edit, :update, :show], param: :key
  end
end
