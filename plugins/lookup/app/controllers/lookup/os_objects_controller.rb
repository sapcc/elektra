# frozen_string_literal: true

module Lookup
  class OsObjectsController < Lookup::ApplicationController
    authorization_context 'lookup'
    authorization_required

    before_action :query_param, except: [:index, :show_object]

    def index
      @types = {}
      allowed_objects = []
      allowed_objects << 'instance'         if current_user.is_allowed?('lookup:os_object_show_instance')
      allowed_objects << 'network_private'  if current_user.is_allowed?('lookup:os_object_show_network_private')
      allowed_objects << 'network_external' if current_user.is_allowed?('lookup:os_object_show_network_external')
      allowed_objects << 'dns_record'       if current_user.is_allowed?('lookup:os_object_show_dns_record')
      allowed_objects << 'project'          if current_user.is_allowed?('lookup:os_object_show_project')
      allowed_objects.each do |type|
        @types[t(type)] = type
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
      redirect_to plugin('identity').project_view_path(id: @query)
    end

    def show_network_private
      redirect_to plugin('networking').networks_private_path(id: @query)
    end

    def show_network_external
      redirect_to plugin('networking').networks_external_path(id: @query)
    end

    def show_dns_record
      # TODO: remove default wildcard search and document capabilities
      # TODO: display all results, not just the first
      record = services.dns_service.recordsets(all_projects: true, name: "*#{@query}*").first
      raise 'no matching record found' unless record
      redirect_to plugin('dns_service').zone_recordset_path(zone_id: record.zone_id, id: record.id)
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
