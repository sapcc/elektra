%{PLUGIN_NAME}::Engine.routes.draw do
  scope "/:domain_id/:project_id" do
    get '/' => 'application#index'
  end
end
