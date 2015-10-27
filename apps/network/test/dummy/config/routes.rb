Rails.application.routes.draw do

  mount Network::Engine => "/network"
end
