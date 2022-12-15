module Compute
  module Hypervisors
    class ServersController < Compute::HypervisorsController
      def index
        page = params[:page] || 1
        per_page = 20

        servers = services.compute.hypervisor_servers(@hypervisor.name)
        count = servers.count
        @hypervisor_servers =
          (
            if count
              Kaminari
                .paginate_array(servers, total_count: count)
                .page(page)
                .per(per_page)
            else
              Kaminari.paginate_array([]).page(1)
            end
          )
      end
    end
  end
end
