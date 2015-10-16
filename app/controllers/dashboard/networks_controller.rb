class Dashboard::NetworksController < DashboardController
  def index
    @networks = services.network.networks
    puts @networks.first.pretty_attributes
  end
  
  def show
    @network = services.network.network(params[:id])
    @subnets = services.network.subnets(@network.id)
    @ports   = services.network.ports(@network.id)
  end
  
  def new
    @forms_network = services.network.network
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
