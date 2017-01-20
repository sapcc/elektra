module Compute
  module Hypervisors
    class ServersController < Compute::HypervisorsController
      def index
        page = params[:page] || 1
        per_page = 20

        servers = services.compute.hypervisor_servers(@hypervisor.name)
        @hypervisor_servers = Kaminari.paginate_array(servers, total_count: servers.count).page(page).per(per_page)
      end
    end
  end
end
