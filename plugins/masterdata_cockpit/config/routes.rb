MasterdataCockpit::Engine.routes.draw do
  
  scope '/', as: 'masterdata' do
    get  '/' => 'project_masterdata#index'
  end

end
