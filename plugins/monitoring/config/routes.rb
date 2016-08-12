Monitoring::Engine.routes.draw do
  get '/' => 'entry#index', as: 'entry'
  get 'overview' => 'overview#index'

  resources 'alarms', except: [:new, :create] do
    collection do
      get 'filter' => 'alarms#filter_and_search'
      get 'search' => 'alarms#filter_and_search'
    end
    get 'history'
  end

  resources 'alarm_definitions' do
    collection do
      get 'search'
      get 'create_expression'
      get 'dimensions_by_metric' => 'alarm_definitions#get_dimensions_by_metric'
      get 'dimension_row'
    end
    member do
      get 'toggle_alarm_actions'
    end
  end

  resources 'notification_methods' do
    collection do
      get 'search'
    end
  end

end
