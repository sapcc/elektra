Compute::Engine.routes.draw do
  resources :instances, except: [:edit, :update] do
    member do
      get 'console'
      get 'update_item'
      get 'new_floatingip'
      get 'new_size'
      put 'resize'
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
end
