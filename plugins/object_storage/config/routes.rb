ObjectStorage::Engine.routes.draw do

  resources 'containers', param: :container

  scope 'containers/:container', format: false do
    # a simple `resources :objects` won't work since the object path shall be
    # in the URL directly and can contain literally anything, so we need to
    # put all action names etc. before it
    get 'list(/*path)' => 'objects#index',    as: 'list_objects'
    get 'raw/*path'    => 'objects#download', as: 'download_object'
    get 'show/*path'   => 'objects#show',     as: 'object'
  end

end
