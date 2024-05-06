ObjectStorage::Engine.routes.draw do
  # get "swift", to: "application#swift", as: :swift
  # get "ceph", to: "application#ceph", as: :ceph

  # root to: "application#swift", as: :widget

  # get "check-acls" => "application#check_acls"

  # # catch all other paths and point them to root
  # get "swift/*path", to: "application#swift"
  # get "ceph/*path", to: "application#ceph"
  # # get "*path", to: "application#show", via: :all

  get ":service_name", to: "application#show", as: :service
  get ":service_name/*path", to: "application#show"
end
