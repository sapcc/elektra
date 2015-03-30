Rails.application.routes.draw do

  root 'services#index'

  resources :instances, only: [:index]

end
