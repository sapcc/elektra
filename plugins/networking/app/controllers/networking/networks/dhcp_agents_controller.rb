# frozen_string_literal: true

module Networking
  # Implements Network Rbac actions
  class Networks::DhcpAgentsController < NetworksController
    def index
      @dhcp_agents = services_ng.networking.network_dhcp_agents(@network_id)
      @new_dhcp_agents = services_ng.networking.dhcp_agents.delete_if{ |existing_agent| @dhcp_agents.map(&:id).include?(existing_agent.id) }
    end

    def create
      @dhcp_agent = services_ng.networking.new_dhcp_agent(params[:dhcp])
      @dhcp_agent.network_id = @network_id
      @dhcp_agent.save
    end

    def destroy
      @dhcp_agent = services_ng.networking.new_dhcp_agent
      @dhcp_agent.id = params[:id]
      @dhcp_agent.network_id = @network_id

      if @dhcp_agent.destroy
        flash.now[:notice] = 'DHCP Agent successfully removed.'
      else
        flash.now[:error] = @dhcp_agent.errors.full_messages.to_sentence
      end

      respond_to do |format|
        format.js {}
        format.html do
          redirect_to plugin('networking').send(
            "networks_#{@network_type}_dhcp_agents_path"
          )
        end
      end
    end

    private

    def load_type
      @network_type = params.key?('private_id') ? 'private' : 'external'
      @network_id   = params["#{@network_type}_id"]
    end
  end
end
