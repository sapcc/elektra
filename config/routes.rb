Rails.application.routes.draw do

  mount MonsoonOpenstackAuth::Engine => '/auth'
  root 'services#index'

  scope "/(:domain)", defaults: {domain: "o-sap_public"} do
    resources :instances, only: [:index]
  end

end
