require 'ipaddr'

module Networking
  module SecurityGroups
    class RulesController < ::DashboardController

      def new
        @security_groups = services.networking.security_groups(tenant_id: @scoped_project_id)
        @security_group = @security_groups.select{|sg| sg.id==params[:security_group_id]}.first
        @rule_type = Networking::SecurityGroupRule::PREDEFINED_RULE_TYPES.keys.first

        rule_template = Networking::SecurityGroupRule::PREDEFINED_RULE_TYPES[@rule_type]
        range = (rule_template['port_range'] || '').split('-')
        attributes = {
          protocol: rule_template['protocol'].blank? ?  'tcp' : rule_template['protocol'],
          direction: rule_template['direction'].blank? ?  'ingress' : rule_template['direction'],
          port_range_min: range.first,
          port_range_max: range.last,
          remote_ip_prefix: '0.0.0.0/0'
        }
        @rule = services.networking.new_security_group_rule(attributes)

        @quota_data = services.resource_management.quota_data([
          {service_name: :networking, resource_name: :security_group_rules}
        ])
      end

      def create
        rule_params = params[:security_group_rule]
        @rule_type = rule_params.delete(:type)

        unless rule_params.blank?
          attributes = {
            protocol: rule_params[:protocol],
            direction: rule_params[:direction],
            security_group_id: params[:security_group_id]
          }

          if rule_params[:protocol] == 'icmp'
            attributes[:port_range_min] = rule_params[:icmp_type] unless rule_params[:icmp_type].blank?
            attributes[:port_range_max] = rule_params[:icmp_code] unless rule_params[:icmp_code].blank?
          else
            range = (rule_params[:port_range] || '').split('-')
            attributes[:port_range_min] = range.first
            attributes[:port_range_max] = range.last
          end

          if rule_params[:remote_source]=='remote_ip_prefix'
            attributes[:remote_ip_prefix]=rule_params[:remote_ip_prefix]
            unless rule_params[:remote_ip_prefix].blank?
              ip = IPAddr.new rule_params[:remote_ip_prefix]
              if ip.ipv4?
                attributes[:ethertype] = 'ipv4'
              elsif ip.ipv6?
                attributes[:ethertype] = 'ipv6'
              end
            else
              attributes[:ethertype] = 'ipv4'
            end
          elsif rule_params[:remote_source]=='remote_group_id'
            attributes[:remote_group_id]=rule_params[:remote_group_id]
          end

          @rule = services.networking.new_security_group_rule(attributes)
        end

        if @rule && @rule.save
          redirect_to security_group_path(params[:security_group_id])
        else
          @security_groups = services.networking.security_groups(tenant_id: @scoped_project_id)
          @security_group = @security_groups.select{|sg| sg.id==params[:security_group_id]}.first

          @quota_data = services.resource_management.quota_data([
            {service_name: :networking, resource_name: :security_group_rules}
          ])
          render action: :new
        end

      end

      def show

      end

      def destroy
        @rule = services.networking.find_security_group_rule(params[:id]) rescue nil

        if @rule
          unless @rule.destroy
            @error = @rule.errors.full_messages.to_sentence
          end
        else
          @error = 'Could not find security group rule.'
        end

        respond_to do |format|
          format.html do
            if @error
              flash.now[:error] = @error
            else
              flash.now[:notice] = 'Security Group Rule successfully deleted!'
            end
            redirect_to security_group_path(params[:security_group_id])
          end
          format.js { }
        end

      end
    end
  end
end
