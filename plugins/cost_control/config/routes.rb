CostControl::Engine.routes.draw do
  get '/cost_center' => 'cost_center#show',   as: 'cost_center'
  put '/cost_center' => 'cost_center#update'
end
