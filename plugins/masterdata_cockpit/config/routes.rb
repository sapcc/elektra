MasterdataCockpit::Engine.routes.draw do
  scope "/project", as: "project_masterdata" do
    get "/" => "project_masterdata#index"
    get "/new" => "project_masterdata#new"
    get "/show" => "project_masterdata#show"
    get "/edit" => "project_masterdata#edit"
    get "/edit_project" => "project_masterdata#edit_project"
    post "/create" => "project_masterdata#create"
    post "/update" => "project_masterdata#update"
    post "/update_project" => "project_masterdata#update_project"
  end

  scope "/domain", as: "domain_masterdata" do
    get "/" => "domain_masterdata#index"
    get "/edit" => "domain_masterdata#edit"
    post "/create" => "domain_masterdata#create"
    post "/update" => "domain_masterdata#update"
  end
end
