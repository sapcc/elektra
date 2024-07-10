Resources::Engine.routes.draw do
  ##############################################################################
  # main views
  #
  # NOTE: "current" used to be ":cluster_id". Since multi-cluster support has
  # been removed from the UI, the value "current" is hardcoded to preserve
  # backwards compatibility.
  
  get "/v2/project" => "v2#project", :as => "v2_project"
  get "/v2/domain" => "v2#domain", :as => "v2_domain"
  get "/v2/cluster" => "v2#cluster", :as => "v2_cluster"
end
