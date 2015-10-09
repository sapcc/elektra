class Dashboard::NetworksController < DashboardController
  def index
    @networks = services.network.networks
  end
  
  def show
    @network = services.network.find_network(params[:id])
    @subnets = services.network.subnets(@network.id)
    @ports   = services.network.ports(@network.id)
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
