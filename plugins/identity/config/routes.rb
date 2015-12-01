Identity::Engine.routes.draw do
  resources :projects, only: [:index]
  
  get 'project/home' => 'projects#show', as: :project
  get 'home' => 'domains#show', as: :domain
  
  resources :credentials
end
