# frozen_string_literal: true

module DnsService
  module Zones
    # recordsets controller
    class RecordsetsController < DnsService::ApplicationController
      before_action ->(id = params[:zone_id]) { load_zone id }
      def show
        @recordset = services.dns_service.find_recordset(
          params[:zone_id], params[:id], @impersonate_option
        )
      end

      def new
        @recordset = services.dns_service.new_recordset(
          @impersonate_option.merge(zone_id: @zone.id)
        )
      end

      def create
        @recordset = services.dns_service.new_recordset(
          @zone.id, params[:recordset]
        )
        @recordset.zone_name = @zone.name
        # convert records string to array, remove spaces and empty entries
        @recordset.records = @recordset.records.split(',')
                                       .collect(&:strip)
                                       .reject(&:empty?)

        if @recordset.save
          flash.now[:notice] = 'Recordset successfully created.'
          respond_to do |format|
            format.html { redirect_to zone_path(@zone.id) }
            format.js { render 'create', formats: :js }
          end
        else
          render action: :new
        end
      end

      def edit
        @action_from_show = params[:action_from_show] || 'false'

        @recordset = services.dns_service.find_recordset(
          @zone.id, params[:id], @impersonate_option
        )
      end

      def update
        @action_from_show = params[:recordset][:action_from_show] == 'true' || false
        @recordset = services.dns_service.find_recordset(
          @zone.id, params[:id], @impersonate_option
        )

        @recordset.records = params[:recordset][:records] || ''
        @recordset.records = @recordset.records.split(',')
                                       .collect(&:strip)
                                       .reject(&:empty?)

        @recordset.description = params[:recordset][:description]
        @recordset.ttl = params[:recordset][:ttl]
        # only impersonate other project if allowed
        @recordset.project_id = nil unless @all_projects

        if @recordset.save
          flash.now[:notice] = 'Recordset successfully updated.'
          respond_to do |format|
            format.html { redirect_to zone_path(@zone.id) }
            format.js { render 'update', formats: :js }
          end

        else
          render action: :edit
        end
      end

      def destroy
        @action_from_show = params[:action_from_show] == 'true' || false

        @deleted = services.dns_service.delete_recordset(
          params[:zone_id], params[:id], all_projects: @all_projects
        )

        @zone_id = params[:zone_id] if @action_from_show

        respond_to do |format|
          format.js {}
          format.html do
            redirect_to zone_path(
              id: params[:zone_id], page: params[:page], marker: params[:marker]
            )
          end
        end
      end
    end
  end
end
