module Loadbalancing
  module Loadbalancers
    module Pools
      class MembersController < DashboardController

        def new
          load_objects
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
          @pool = services.loadbalancing.find_pool(params[:pool_id])
          # OS Bug, Subnet not optional, has to be set to VIP subnet
          vip_subnet_id = nil
          if @pool
            listener_id = @pool.listeners.first['id']
            listener = services.loadbalancing.find_listener(listener_id)
            if listener
              vip_id = listener.loadbalancers.first['id']
              vip = services.loadbalancing.find_loadbalancer(vip_id)
              vip_subnet_id = vip.vip_subnet_id
            end
          end

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

              # Horrible hack for adding members when LB is instate PENDING
              unless member.save
                raise if member.errors.messages.to_s.match("Invalid state PENDING_UPDATE of loadbalancer resource")
                success = false
                member.id = SecureRandom.hex
                @error_members << member
              end
            rescue
              sleep 2
              retry if count < 3
            end
          end if new_servers

          if success
            redirect_to show_details_pool_path(params[:pool_id]), notice: 'Members successfully created.'
          else
            load_objects
            render action: :new
          end
        end

        def destroy
          pool_id = params[:pool_id]
          member_id = params[:id]
          member = services.loadbalancing.find_pool_member(pool_id, member_id)
          pool = services.loadbalancing.find_pool(pool_id)
          if services.loadbalancing.delete_pool_member(pool_id, member_id)
            audit_logger.info(current_user, "has deleted", member)
            redirect_to show_details_pool_path(pool_id), notice: 'Pool Member successfully deleted.'
          else
            redirect_to show_details_pool_path(pool_id),
                        flash: {error: "Pool Member deletion failed -> #{member.errors.full_messages.to_sentence}"}
          end
        end

        private

        def member_params
          p = params[:member].symbolize_keys if params[:member]
          return p
        end

        def load_objects
          @pool = services.loadbalancing.find_pool(params[:pool_id]) if params[:pool_id]
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
