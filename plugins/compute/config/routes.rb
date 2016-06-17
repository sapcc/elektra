Compute::Engine.routes.draw do
  resources :instances, except: [:edit, :update] do
    member do
      get 'console'
      get 'update_item'
      get 'new_floatingip'
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
