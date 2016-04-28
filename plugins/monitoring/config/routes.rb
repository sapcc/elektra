Monitoring::Engine.routes.draw do
  get '/' => 'application#index', as: :entry

  resources 'alarms', except: [:new, :create]
  resources 'alarm_definitions'
  resources 'notification_methods'
end
