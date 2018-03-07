# frozen_string_literal: true

module Networking
  # Implements Security Group actions
  class SecurityGroupsController < DashboardController
    authorization_context 'networking'
    authorization_required

    def index
      @security_groups = services.networking.security_groups(
        tenant_id: @scoped_project_id
      )

      @quota_data = []
      if current_user.is_allowed?("access_to_project")
        @quota_data = services.resource_management.quota_data(
          current_user.domain_id || current_user.project_domain_id,
          current_user.project_id,
          [
            { service_type: :network, resource_name: :security_groups,
              usage: @security_groups.length },
            { service_type: :network, resource_name: :security_group_rules }
          ]
        )
      end
    end

    def new
      @security_group = services.networking.new_security_group(
        tenant_id: @scoped_project_id
      )
    end

    def create
      @security_group = services.networking.new_security_group(
        (params[:security_group] || {}).merge(tenant_id: @scoped_project_id)
      )
      @security_group.save

      if @security_group.errors.empty?
        respond_to do |format|
          format.html { redirect_to security_groups_path }
          format.js {}
        end
      else
        render action: :new
      end
    end

    def edit
      @security_group = services.networking.find_security_group(params[:id])
    end

    def update
      @security_group = services.networking.new_security_group(
        (params[:security_group] || {}).merge(tenant_id: @scoped_project_id)
      )
      @security_group.id = params[:id]
      @security_group.save

      if @security_group.errors.empty?
        respond_to do |format|
          format.html { redirect_to :back }
          format.js {}
        end
      else
        render action: :edit
      end
    end

    def show
      @security_group = services.networking.find_security_group(params[:id])
      if @security_group.blank?
        flash.now[:error] = "We couldn't retrieve the security group details. Please try again."
      else
        enforce_permissions('networking:rule_list')
        @rules = services.networking.security_group_rules(
          security_group_id: @security_group.id
        ).sort_by do |rule|
          sprintf("%s-%s-%s-%05d-%05d-%s",
            rule.direction.presence || 'unknown',
            rule.ethertype.presence || 'unknown',
            rule.protocol.presence  || 'unknown',
            rule.port_range_min.presence || 00000,
            rule.port_range_max.presence || 99999,
            # sort by ID as last resort to ensure stable ordering
            rule.id,
          )
        end
        # @security_groups = {}
        # @rules.each do |rule|
        #   unless @security_groups[rule.remote_group_id]
        #     if rule.remote_group_id == @security_group.id
        #       @security_groups[rule.remote_group_id] = @security_group
        #     else
        #       @security_groups[rule.remote_group_id] =
        #         services.networking.find_security_group(rule.remote_group_id)
        #     end
        #   end
        #   if @security_groups[rule.remote_group_id]
        #     rule.remote_group_name = @security_groups[rule.remote_group_id].name
        #   end
        # end

        @security_groups = @rules.each_with_object({}) do |rule, hash|
          next if rule.remote_group_id.blank?
          unless hash[rule.remote_group_id]
            if rule.remote_group_id == @security_group.id
              hash[rule.remote_group_id] = @security_group
            else
              hash[rule.remote_group_id] =
                services.networking.find_security_group(rule.remote_group_id)
            end
          end
          rule.remote_group_name = hash[rule.remote_group_id].name
        end

        @quota_data = []
        if current_user.is_allowed?("access_to_project")
          @quota_data = services.resource_management.quota_data(
            current_user.domain_id || current_user.project_domain_id,
            current_user.project_id,
            [
              { service_type: :network, resource_name: :security_groups,
                usage: @security_groups.length },
              { service_type: :network, resource_name: :security_group_rules,
                usage: @rules.length }
            ]
          )
        end
      end
    end

    def destroy
      @security_group = services.networking.new_security_group
      @security_group.id = params[:id]

      unless @security_group.destroy
        @error = @security_group.errors.full_messages.to_sentence
      end

      respond_to do |format|
        format.html do
          if @error
            flash.now[:error] = @error
          else
            flash.now[:notice] = 'Security Group successfully deleted!'
          end
          redirect_to security_groups_path
        end
        format.js {}
      end
    end
  end
end
