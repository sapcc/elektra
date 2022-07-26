ObjectStorageNg::Engine.routes.draw do
  root to: 'application#show', as: :widget
  get 'check-acls' => 'application#check_acls'
end
