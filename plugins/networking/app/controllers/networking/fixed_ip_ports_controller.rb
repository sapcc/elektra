# frozen_string_literal: true

module Networking
  # Implements Port actions
  class FixedIpPortsController < DashboardController
    # set policy context
    authorization_context 'networking'
    # enforce permission checks. This will automatically
    # investigate the rule name.
    authorization_required only: %i[index create delete]

    def index
      per_page = params[:per_page] || 15
      ports = paginatable(per_page: per_page) do |pagination_options|
        services.networking.fixed_ip_ports({ sort_key: 'id'}.merge(pagination_options))
      end

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if request.xhr?
        render json: { ports: ports[0..per_page - 1], has_next: ports.length > per_page }
      else
        # common case, render index page with layout
        render action: :index
      end
    end

    def show
      port = services.networking.find_port(params[:id])
      enforce_permissions('::networking:port_get', port: port)
      render json: port
    end

    def create

    end

    def destroy

    end
  end
end
