Identity::Engine.routes.draw do
  resources :projects, only:[:index] do
    get 'wizard' => 'projects#wizard', on: :collection
    post 'wizard' => 'projects#wizard_create', on: :collection
  end
  
  get 'project/home' => 'projects#show', as: :project
  get 'home' => 'domains#show', as: :domain
  
  resources :credentials
end
