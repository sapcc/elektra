Inquiry::Engine.routes.draw do
  resources :inquiries

  namespace :admin do
    resources :inquiries
  end

end
