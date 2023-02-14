Inquiry::Engine.routes.draw do
  resources :inquiries, path: "/items"

  namespace :admin do
    resources :inquiries, path: "/items"
  end
end
