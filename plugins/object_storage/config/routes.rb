ObjectStorage::Engine.routes.draw do

  get '/' => 'entry#index', as: 'entry'

  resources 'containers', except: :edit do
    member do
      get  :confirm_deletion
      get  :confirm_emptying
      post :pre_empty
      post :empty
      get  :show_access_control
      post :update_access_control
      get  :check_acls
    end
  end

  scope 'containers/:container', constraints: { container: /[^\/]+/ }, format: false do
    # a simple `resources :objects` won't work since the object path shall be
    # in the URL directly and can contain literally anything, so we need to
    # put all action names etc. before it
    get    'list(/*path)'      => 'objects#index',       as: 'list_objects'
    get    'raw/*path'         => 'objects#download',    as: 'download_object'
    get    'object/*path'      => 'objects#show',        as: 'object'
    post   'object/*path'      => 'objects#update',      as: 'update_object'
    delete 'object/*path'      => 'objects#destroy',     as: 'destroy_object'
    get    'copy/*path'        => 'objects#new_copy',    as: 'new_copy'
    post   'copy/*path'        => 'objects#create_copy', as: 'create_copy'
    get    'move/*path'        => 'objects#move',        as: 'move_object'

    get    'upload(/*path)'        => 'folders#new_object',    as: 'new_object'
    post   'upload(/*path)'        => 'folders#create_object', as: 'create_object'
    get    'create_folder(/*path)' => 'folders#new_folder',    as: 'new_folder'
    post   'create_folder(/*path)' => 'folders#create_folder', as: 'create_folder'
    delete 'folder/*path'          => 'folders#destroy',       as: 'destroy_folder'
  end

end
