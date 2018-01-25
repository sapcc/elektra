# frozen_string_literal: true

module Networking
  # Implements Port actions
  class PortsController < DashboardController
    # set policy context
    authorization_context 'networking'
    # enforce permission checks. This will automatically
    # investigate the rule name.
    authorization_required only: %i[index]

    def index
      per_page = params[:per_page] || 15
      @ports = paginatable(per_page: per_page) do |pagination_options|
        services.networking.ports({ sort_key: 'id'}.merge(pagination_options))
      end

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if request.xhr?
        render partial: 'list', locals: { ports: @ports }
      else
        # common case, render index page with layout
        render action: :index
      end
    end

    def show
      @port = services.networking.find_port(params[:id])
      enforce_permissions('::networking:port_get', port: @port)
    end

    def destroy

    end
  end
end
