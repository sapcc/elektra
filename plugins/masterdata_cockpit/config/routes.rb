MasterdataCockpit::Engine.routes.draw do
  
  scope '/project', as: 'project_masterdata' do
    get  '/' => 'project_masterdata#index'
  end

  scope '/domain', as: 'domain_masterdata' do
    get  '/' => 'domain_masterdata#index'
  end
end
