Resources::Engine.routes.draw do
  get '/project/:cluster_id/:override_domain_id/:override_project_id' \
                 => 'application#project', as: 'foreign_project'
  get '/project' => 'application#project', as: 'project'

  get '/domain/:cluster_id/:override_domain_id' \
                => 'application#domain', as: 'foreign_domain'
  get '/domain' => 'application#domain', as: 'domain'

  get '/cluster/:cluster_id' => 'application#cluster', as: 'cluster'
end
