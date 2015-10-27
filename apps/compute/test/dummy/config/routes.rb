Rails.application.routes.draw do

  mount Compute::Engine => "/compute"
end
