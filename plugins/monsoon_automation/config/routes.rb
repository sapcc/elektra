MonsoonAutomation::Engine.routes.draw do
  scope "/:domain_id/:project_id/" do
    get '/automation' => 'automation#index'
  end
end