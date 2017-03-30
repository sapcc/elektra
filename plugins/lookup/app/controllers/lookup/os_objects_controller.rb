module Lookup
  class OsObjectsController < Lookup::ApplicationController
    authorization_context 'lookup'
    authorization_required

    before_filter :query_param, except: [:index, :show_object]

    def index
      @types = {}
      allowed_objects = []
      allowed_objects << 'instance'         if current_user.is_allowed?('lookup:os_object_show_instance')
      allowed_objects << 'network_private'  if current_user.is_allowed?('lookup:os_object_show_network_private')
      allowed_objects << 'network_external' if current_user.is_allowed?('lookup:os_object_show_network_external')
      allowed_objects.each do |type|
        @types[type.humanize] = type
      end
      @os_object = Lookup::OsObject.new(nil)
    end

    def show_object
      os_object = params['os_object']
      @query = os_object['query']
      lookup_method = os_object['lookup_method']
      send("#{lookup_method}_#{os_object['os_type']}")
    end

    def show_instance
      redirect_to plugin('compute').instance_path(id: @query)
    end

    def show_project
      raise 'not implemented'
      # project#show currently only can display the active project
      # redirect_to plugin('identity').project_path(id: @query)
    end

    def show_network_private
      redirect_to plugin('networking').networks_private_path(id: @query)
    end

    def show_network_external
      redirect_to plugin('networking').networks_external_path(id: @query)
    end

    private

    def query_param
      return if @query
      @query = params[:query]
      raise 'query parameter missing' unless @query
    end

    def release_state
      'experimental'
    end
  end
end
