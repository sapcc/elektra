# frozen_string_literal: true

Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'
  # mount MonsoonOpenstackAuth::Engine => '/:auth_domain/auth'

  # lifeliness
  # check without db connection. It only checks that a request reaches
  # the Middleware layer, and nothing else.
  # /system/liveliness is frozen in the MiddlewareHealthcheck to reduce
  # object allocation
  scope '/system' do
    # readiness, check with db connection
    get :readiness, to: 'health#show'
    # TODO: remove the health path when we are sure it is not anymore
    # being used.
    get :health, to: 'health#show'
  end

  scope '/:domain_id' do
    match '/', to: 'pages#show', id: 'landing', via: :get, as: :landing_page

    scope '(/:project_id)' do
      scope module: 'dashboard' do
        post 'accept_terms_of_use'
        get 'terms_of_use'
        get 'find_users_by_name'
        get 'find_cached_projects'
      end

      ###################### MOUNT PLUGINS #####################
      Core::PluginsManager.mountable_plugins.each do |plugin|
        next if ['docs'].include?(plugin.name)
        Logger.new(STDOUT).debug(
          "Mount plugin #{plugin.mount_point} as #{plugin.name}_plugin"
        )
        # mount point is the name of the plugin
        mount plugin.engine_class => "/#{plugin.mount_point}",
              as: "#{plugin.name}_plugin"
      end
      ######################## END ############################
    end
  end

  scope module: 'identity' do
    get '/:domain_id/:project_id' => 'projects#show', as: :project_home
  end

  # route for overwritten High Voltage Pages controller
  get '/pages/*id' => 'pages#show', as: :core_page, format: false

  # root to: 'pages#show', id: 'landing'

  root(to: redirect do |_params, request|
    domain_id = request.query_parameters['domain_id']
    "/#{domain_id || Rails.application.config.default_domain}"
  end)

  # route all other urls to 404 page ignoring all formats except html
  get '*path', to: 'errors#error_404', via: :all,
               constraints: ->(req) { req.format == :html }
end
