Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'
  root 'services#index'

  scope "/(:domain_id)/(:project_id)" do
    scope module: 'authenticated_user' do
      resources :instances
      resources :volumes
      resources :images
      
      get 'users/terms_of_use'
      get 'users/register'
    end
  end

end
