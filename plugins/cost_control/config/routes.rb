CostControl::Engine.routes.draw do
  get '/cost-object' => 'cost_object#show',   as: 'cost_object'
  put '/cost-object' => 'cost_object#update'
end
