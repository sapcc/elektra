ObjectStorage::Engine.routes.draw do

  resources 'containers', param: :container, except: :edit do
    member do
      get :confirm_deletion
    end
  end

  scope 'containers/:container', format: false do
    # a simple `resources :objects` won't work since the object path shall be
    # in the URL directly and can contain literally anything, so we need to
    # put all action names etc. before it
    get  'list(/*path)'        => 'objects#index',       as: 'list_objects'
    get  'raw/*path'           => 'objects#download',    as: 'download_object'
    get  'object/*path'        => 'objects#show',        as: 'object'
    post 'object/*path'        => 'objects#update',      as: 'update_object'

    get  'upload(/*path)'        => 'folders#new_object',    as: 'new_object'
    post 'upload(/*path)'        => 'folders#create_object', as: 'create_object'
    get  'create_folder(/*path)' => 'folders#new_folder',    as: 'new_folder'
    post 'create_folder(/*path)' => 'folders#create_folder', as: 'create_folder'
  end

end
