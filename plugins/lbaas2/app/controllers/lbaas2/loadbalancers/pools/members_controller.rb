require 'rack'

module Lbaas2
  module Loadbalancers
    module Pools
      class MembersController < ApplicationController
        authorization_context 'lbaas2'
        authorization_required

        def index
          per_page = (params[:per_page] || 9999).to_i
          pagination_options = { sort_key: 'name', sort_dir: 'asc', limit: per_page + 1 }
          pagination_options[:marker] = params[:marker] if params[:marker]
          
          members = services.lbaas2.members(params[:pool_id], pagination_options)
          render json: {
            members: members
          }
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end

        def show
          member = services.lbaas2.find_member(params[:pool_id], params[:id])
          render json: {
            member: member
          }
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end  

        def create
          membersParams = parseMemberParams()
          # OS Bug, Subnet not optional, has to be set to VIP subnet          
          loadbalancer = services.lbaas2.find_loadbalancer(params[:loadbalancer_id])
          vip_subnet_id = loadbalancer.vip_subnet_id

          success = true
          errors = []
          saved_members = []
          results = {}
          membersParams.each do |k,values|
            # convert tags to array do to parse_nested_query
            unless values["tags"].blank?              
              values["tags"] = JSON.parse(values["tags"])
            end
            newParams = values.merge(pool_id: params[:pool_id],  subnet_id: vip_subnet_id, project_id: @scoped_project_id)
            member = services.lbaas2.new_member(newParams)

            if member.save
              results[member.identifier] = member.attributes.merge({saved: true})
              saved_members << member
              audit_logger.info(current_user, 'has created', member)
            else
              success = false
              results[member.identifier] = member.attributes.merge({saved: false})
              errors << {"row #{member.index}": member.errors}
            end      
          end

          if success
            render json: saved_members.first
          else
            sortedErrors = errors.sort_by { |hsh| hsh.keys.first }
            render json: {errors: sortedErrors, results: results}, status: 422
          end
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end

        def destroy
          member = services.lbaas2.new_member
          member.id = params[:id]

          if member.destroy
            audit_logger.info(current_user, 'has deleted', member)
            head 202
          else  
            render json: { errors: listener.errors }, status: 422
          end
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end

        def serversForSelect
          # get all servers
          per_page = params[:per_page] || 9999
          per_page = per_page.to_i
          servers = paginatable(per_page: per_page) do |pagination_options|
            services.compute.servers(pagination_options)
          end

          # select all available floating ips attached to the servers
          select_servers = []
          servers.each do |server|
            server.addresses.each do |_network_name, ip_values|
              next unless ip_values && !ip_values.empty?
              ip_values.each do |value|
                next unless value['OS-EXT-IPS:type'] == 'fixed'                
                select_servers << {"label": "#{value['addr']} - #{server.name} (#{server.id})", "value": value['addr'], "address": value['addr'], "name": server.name, "id": server.id}
              end
            end
          end

          render json: {
            servers: select_servers
          }
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end

        protected
  
        def parseMemberParams()
          membersParams = params[:member]
          newMemberParams = {}
          membersParams.each do|k, v|
            newMemberParams = newMemberParams.deep_merge(Rack::Utils.parse_nested_query("#{k}=#{v}")["member"])
          end          
          newMemberParams
        end

      end
    end
  end
end