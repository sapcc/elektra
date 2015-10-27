Rails.application.routes.draw do

  mount Identity::Engine => "/identity"
end
