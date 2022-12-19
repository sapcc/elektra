Tools::Engine.routes.draw do
  root to: "application#show", as: :start
  get "/castellum" => "castellum#show", :as => :castellum_errors
  get "/limes" => "limes#show", :as => :limes_errors
end
