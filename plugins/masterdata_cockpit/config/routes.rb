MasterdataCockpit::Engine.routes.draw do
  
  scope '/project', as: 'project_masterdata' do
    get  '/' => 'project_masterdata#index'
    get  '/new' => 'project_masterdata#new'
    post '/create' => 'project_masterdata#create'
  end

  scope '/domain', as: 'domain_masterdata' do
    get  '/' => 'domain_masterdata#index'
  end
end
