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

  scope "/(:domain_id)" do
    scope module: 'authenticated_user' do
      resources :projects, only: [:new, :create, :index, :show, :destroy]
    end
  end

  scope "/system" do
    get :health, to: "health#show"
  end
end
