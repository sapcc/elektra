Webconsole::Engine.routes.draw do
  get '/' => 'application#show', as: :root
  get '/credentials' => 'application#credentials'
end
