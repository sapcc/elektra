Rails.application.routes.draw do

  mount MonsoonOpenstackAuth::Engine => '/auth'
  root 'services#index'

  resources :instances, only: [:index]

end
