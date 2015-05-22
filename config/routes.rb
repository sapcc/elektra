Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'
  root 'services#index'

  scope "/(:domain_id)/(:project_id)" do
    scope module: 'authenticated_user' do
      resources :instances
      resources :volumes
      resources :images
      resources :users, only: [:new, :create]
    end
  end

  scope "/system" do
    resource :health, only: [:index]
  end
end
