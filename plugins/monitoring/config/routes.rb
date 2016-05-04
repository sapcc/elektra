Monitoring::Engine.routes.draw do
  get '/' => 'overview#index', as: :entry

  get 'alarm_definitions/search/' => 'alarm_definitions#search'
  get 'notification_methods/search/' => 'notification_methods#search'
  
  resources 'alarms', except: [:new, :create]
  resources 'alarm_definitions' do
    member do
      get 'toggle_alarm_actions'
    end
  end
  resources 'notification_methods'
end
