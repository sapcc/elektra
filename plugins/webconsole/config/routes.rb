Webconsole::Engine.routes.draw do
  get "/" => "application#show", :as => :root
  get "/current-context" => "application#current_context", :as => :context
end
