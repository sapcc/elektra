ObjectStorageNg::Engine.routes.draw do
  root to: "application#show", as: :widget
  get "check-acls" => "application#check_acls"

  # catch all other paths and point them to root
  get "*path", to: "application#show", via: :all
end
