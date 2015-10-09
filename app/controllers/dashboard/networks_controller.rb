class Dashboard::NetworksController < DashboardController
  def index
    @networks = services.neutron.networks
  end
  
  def show
    @network = services.neutron.find_network(params[:id])
    @subnets = services.neutron.subnets(@network.id)
    @ports   = services.neutron.ports(@network.id)
  end
  
  def new
  end
  
  def create
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end
end
