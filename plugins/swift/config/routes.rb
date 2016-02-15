Swift::Engine.routes.draw do
  get '/' => 'application#index'

  resources 'containers'

end
