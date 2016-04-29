Monitoring::Engine.routes.draw do
  get '/' => 'application#index', as: :entry

  get 'alarm_definitions/search/' => 'alarm_definitions#search'
  get 'notification_methods/search/' => 'alarm_definitions#search'
  
  resources 'alarms', except: [:new, :create]
  resources 'alarm_definitions'
  resources 'notification_methods'
end
