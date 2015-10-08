class Dashboard::NetworksController < DashboardController
  def index
    @networks = services.neutron.networks
    p ">>>>>>>>>>>"
    p @networks
  end
  
  def show
    @network = services.neutron.find_network(params[:id])
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
