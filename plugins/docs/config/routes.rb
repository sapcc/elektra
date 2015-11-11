Docs::Engine.routes.draw do
  # docs are available under /:domain_id/docs or only /docs
  # documentation pages are available under pages/:id
  get "/*id" => 'pages#show', as: :docs_page, format: false
  # start page
  get "/" => 'pages#show', id: 'start', as: :docs  
end
