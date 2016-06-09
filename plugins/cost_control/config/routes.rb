CostControl::Engine.routes.draw do
  get '/cost-object'      => 'cost_object#show',  as: 'cost_object'
  get '/cost-object/edit' => 'cost_object#edit',  as: 'edit_cost_object'
  put '/cost-object'      => 'cost_object#update'
end
