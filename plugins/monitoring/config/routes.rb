Monitoring::Engine.routes.draw do
  get '/' => 'application#index', as: :entry

  get 'alarm_definitions/filter/' => 'alarm_definitions#filter'
  resources 'alarms', except: [:new, :create]
  resources 'alarm_definitions' do
  end

  resources 'notification_methods'
end
