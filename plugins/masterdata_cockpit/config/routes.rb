MasterdataCockpit::Engine.routes.draw do
  
  scope '/project', as: 'project_masterdata' do
    get  '/'       => 'project_masterdata#index'
    get  '/show'   => 'project_masterdata#show'
    get  '/edit'   => 'project_masterdata#edit'
    post '/create' => 'project_masterdata#create'
    post '/update' => 'project_masterdata#update'
    get  '/revenue_relevances' => 'project_masterdata#solution_revenue_relevances'
    get  '/solution' => 'project_masterdata#solution_data'
  end

  scope '/domain', as: 'domain_masterdata' do
    get  '/'       => 'domain_masterdata#index'
    get  '/edit'   => 'domain_masterdata#edit'
    post '/create' => 'domain_masterdata#create'
    post '/update' => 'domain_masterdata#update'
  end
end
