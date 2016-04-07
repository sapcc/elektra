Monitoring::Engine.routes.draw do
  get '/' => 'application#index', as: :entry

  resources 'alarms', except: [:new, :create] do
  end
  
  resources 'alarm_definitions' do
  end
  
  resources 'notifications' do
  end
end
