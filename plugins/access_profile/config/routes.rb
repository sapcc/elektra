AccessProfile::Engine.routes.draw do
  root to: "application#access_profile_widget"
  resources :tags, only: %i[index create destroy] do
    collection { get "config" => "tags#profiles_config" }
  end
end
