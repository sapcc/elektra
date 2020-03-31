Tools::Engine.routes.draw do
  root to: 'application#show', as: :start
  get '/castellum' => 'castellum#show', as: :castellum_errors
end
