module Loadbalancing
  module Loadbalancers
    module Pools
      class MembersController < DashboardController

        before_filter :load_objects, only: [:new, :destroy, :update_item, :create]

        def new
          load_members
        end

        def add
          ips = params['ips'] || []
          @new_members = []
          ips.each do |ip|
            next unless ip.second == '1'
            member = services.loadbalancing.new_pool_member(id: SecureRandom.hex)
            member.attributes = {pool_id: params[:pool_id], address: ip.first, weight: 1}
            @new_members << member
          end
          render 'loadbalancing/loadbalancers/pools/members/add_members.js'
        end

        def add_external
          @new_members = []
          member = services.loadbalancing.new_pool_member(id: SecureRandom.hex)
          member.attributes = {pool_id: params[:pool_id], address: nil, weight: 1}
          @new_members << member
          render 'loadbalancing/loadbalancers/pools/members/add_members.js'
        end

        def create
          # OS Bug, Subnet not optional, has to be set to VIP subnet
          vip_subnet_id = @loadbalancer.vip_subnet_id

          new_servers = params[:servers]
          @error_members = []
          success = true
          new_servers.each do |new_member|
            count = 0
            begin
              count += 1
              member = services.loadbalancing.new_pool_member
              member.attributes = {pool_id: params[:pool_id], address: new_member['address'], protocol_port: new_member['protocol_port'],
                                   weight: new_member['weight'], subnet_id: vip_subnet_id}

              # Horrible hack for adding members when LB is in state PENDING
              unless member.save
                raise if member.errors.messages.to_s.match("Invalid state PENDING_UPDATE of loadbalancer resource")
                success = false
                member.id = SecureRandom.hex
                @error_members << member
              end
            rescue
              sleep 1
              retry if count < 10
            end
          end if new_servers

          if success
            redirect_to show_details_loadbalancer_pool_path(id: params[:pool_id], loadbalancer_id: params[:loadbalancer_id]), notice: 'Members successfully created.'
          else
            load_objects
            load_members
            render action: :new
          end
        end

        def destroy
          pool_id = params[:pool_id]
          member_id = params[:id]
          @member = services.loadbalancing.find_pool_member(pool_id, member_id)
          if services.loadbalancing.delete_pool_member(pool_id, member_id)
            @member.in_transition = true
            audit_logger.info(current_user, "has deleted", @member)
            render template: 'loadbalancing/loadbalancers/pools/members/update_item.js'
            #redirect_to show_details_loadbalancer_pool_path(pool_id)
          else
            redirect_to show_details_loadbalancer_pool_path(id: pool_id, loadbalancer_id: @loadbalancer.id),
                        flash: {error: "Pool Member deletion failed -> #{@member.errors.full_messages.to_sentence}"}
          end
        end

        # update instance table row (ajax call)
        def update_item
          begin
            @member = services.loadbalancing.find_pool_member(@pool.id, member_id)
            @member.in_transition = true
            respond_to do |format|
              format.js do
                @member if @member
              end
            end
          rescue => e
            return nil
          end
        end

        private

        def member_params
          p = params[:member].symbolize_keys if params[:member]
          return p
        end

        def load_objects
          @pool = services.loadbalancing.find_pool(params[:pool_id])
          @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
        end

        def load_members
          @members = services.loadbalancing.pool_members(@pool.id) if @pool
          @ips = []
          @servers = services.compute.servers
          @servers.each do |server|
            server.addresses.each do |network_name, ip_values|
              if ip_values and ip_values.length>0
                ip_values.each do |value|
                  if value["OS-EXT-IPS:type"]=='fixed'
                    ip = Ip.new nil
                    ip.ip = value['addr']
                    ip.name = server.name
                    @ips << ip
                  end
                end
              end
            end
          end
        end

      end
    end
  end
end
