Docs::Engine.routes.draw do
  # docs are available under /:domain_id/docs or only /docs
  scope '/(:domain_id)/docs' do
    # documentation pages are available under pages/:id
    get "pages/*id" => 'pages#show', as: :docs_page, format: false
    # start page
    get "pages/start" => 'pages#show', id: 'start', as: :docs  
  end
end
