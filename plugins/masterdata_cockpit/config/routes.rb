MasterdataCockpit::Engine.routes.draw do
  
  scope '/project', as: 'project_masterdata' do
    get  '/' => 'project_masterdata#index'
    get  '/new' => 'project_masterdata#new'
    get  '/edit' => 'project_masterdata#edit'
    post '/create' => 'project_masterdata#create'
    post '/update' => 'project_masterdata#update'
  end

  scope '/domain', as: 'domain_masterdata' do
    get  '/' => 'domain_masterdata#index'
    get  '/new' => 'domain_masterdata#new'
    get  '/edit' => 'domain_masterdata#edit'
    post '/create' => 'domain_masterdata#create'
    post '/update' => 'domain_masterdata#update'
  end
end
