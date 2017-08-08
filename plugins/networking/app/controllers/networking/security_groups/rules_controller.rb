# frozen_string_literal: true

require 'ipaddr'

module Networking
  module SecurityGroups
    # Implements Security Group Rule actions
    class RulesController < ::DashboardController
      def new
        @security_groups = services_ng.networking.security_groups(
          tenant_id: @scoped_project_id
        )
        @security_group = @security_groups.select  do |sg|
          sg.id == params[:security_group_id]
        end.first
        @rule_type = Networking::SecurityGroupRule::PREDEFINED_RULE_TYPES.keys.first

        rule_template = Networking::SecurityGroupRule::PREDEFINED_RULE_TYPES[@rule_type]
        range = (rule_template['port_range'] || '').split('-')
        attributes = {
          protocol: rule_template['protocol'].blank? ? 'tcp' : rule_template['protocol'],
          direction: rule_template['direction'].blank? ? 'ingress' : rule_template['direction'],
          port_range_min: range.first,
          port_range_max: range.last,
          remote_ip_prefix: '0.0.0.0/0'
        }
        @rule = services_ng.networking.new_security_group_rule(attributes)

        @quota_data = []
        if current_user.is_allowed?("access_to_project")
          @quota_data = services_ng.resource_management.project_quota_data(
            current_user.domain_id || current_user.project_domain_id,
            current_user.project_id,
            [{ service_type: :network, resource_name: :security_group_rules }]
          )
        end
      end

      def create
        rule_params = params[:security_group_rule]
        @rule_type = rule_params.delete(:type)
        rule_params[:security_group_id] = params[:security_group_id]

        attributes = build_rule_attributes(rule_params)
        if attributes
          @rule = services_ng.networking.new_security_group_rule(attributes)
        end

        if @rule && @rule.save
          redirect_to security_group_path(params[:security_group_id])
        else
          @security_groups = services_ng.networking.security_groups(
            tenant_id: @scoped_project_id
          )
          @security_group = @security_groups.select do |sg|
            sg.id == params[:security_group_id]
          end.first


          @quota_data = []
          if current_user.is_allowed?("access_to_project")
            @quota_data = services_ng.resource_management.project_quota_data(
              current_user.domain_id || current_user.project_domain_id,
              current_user.project_id,
              [{ service_type: :network, resource_name: :security_group_rules }]
            )
          end
          render action: :new
        end
      end

      def show; end

      def destroy
        @rule = services_ng.networking.new_security_group_rule
        @rule.id = params[:id]

        @error = @rule.errors.full_messages.to_sentence unless @rule.destroy

        respond_to do |format|
          format.html do
            if @error
              flash.now[:error] = @error
            else
              flash.now[:notice] = 'Security Group Rule successfully deleted!'
            end
            redirect_to security_group_path(params[:security_group_id])
          end
          format.js {}
        end
      end

      protected

      def build_rule_attributes(rule_params)
        return if rule_params.blank?

        attributes = %i[
          description protocol direction security_group_id
        ].each_with_object({}) { |k, hash| hash[k] = rule_params[k] }

        if rule_params[:protocol] == 'icmp'
          unless rule_params[:icmp_type].blank?
            attributes[:port_range_min] = rule_params[:icmp_type]
          end
          unless rule_params[:icmp_code].blank?
            attributes[:port_range_max] = rule_params[:icmp_code]
          end
        else
          range = (rule_params[:port_range] || '').split('-')
          attributes[:port_range_min] = range.first
          attributes[:port_range_max] = range.last
        end

        if rule_params[:remote_source] == 'remote_ip_prefix'
          attributes[:remote_ip_prefix] = rule_params[:remote_ip_prefix]

          if rule_params[:remote_ip_prefix].present?
            ip = begin
                   IPAddr.new(rule_params[:remote_ip_prefix])
                 rescue
                   nil
                 end

            attributes[:ethertype] = 'ipv4' if ip.try(:ipv4?)
            attributes[:ethertype] = 'ipv6' if ip.try(:ipv6?)
          else
            attributes[:ethertype] = 'ipv4'
          end
        elsif rule_params[:remote_source] == 'remote_group_id'
          attributes[:remote_group_id] = rule_params[:remote_group_id]
        end
        attributes
      end
    end
  end
end
