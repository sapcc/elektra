Kubernetes::Engine.routes.draw do
  get '/' => 'application#index', as: :root
end
