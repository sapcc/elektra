Resources::Engine.routes.draw do
  ##############################################################################
  # main views
  #
  # NOTE: "current" used to be ":cluster_id". Since multi-cluster support has
  # been removed from the UI, the value "current" is hardcoded to preserve
  # backwards compatibility.

  get '/project/current/:override_domain_id/:override_project_id' \
                 => 'application#project', as: 'foreign_project'
  get '/project' => 'application#project', as: 'project'
  get '/project/bigvm_resources' => 'application#bigvm_resources', as: 'bigvm_resources'

  get '/domain/current/:override_domain_id' \
                => 'application#domain', as: 'foreign_domain'
  get '/domain' => 'application#domain', as: 'domain'

  get '/cluster/current' => 'application#cluster', as: 'cluster'

  ##############################################################################
  # quota request workflows

  post '/request/project' => 'request#project'
  post '/request/domain'  => 'request#domain'

  get '/project/init' => 'application#init_project', as: 'init_project'

  get  'quota-usage' => 'quota_usage#index'
end
