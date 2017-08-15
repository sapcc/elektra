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
      get 'edit_securitygroups'
      put 'assign_securitygroups'
      put 'lock'
      put 'unlock'
    end
    post 'automation_script', on: :collection
  end

  resources :keypairs

  resources :host_aggregates

  resources :services, constraints: { id: %r{[^\/]+} } do
    member do
      put 'enable'
      put 'disable'
    end
  end

  resources :hypervisors do
    resources :servers, module: :hypervisors, except: [:edit, :update, :show]
  end

  resources :flavors, except: [:show] do
    resources :members, module: :flavors, except: [:edit, :update, :show]
    resources :metadata, module: :flavors, except: [:edit, :update, :show], param: :key
  end
end
