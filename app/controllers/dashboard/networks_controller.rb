class Dashboard::NetworksController < DashboardController
  def index
    @networks = services.network.project_networks(@scoped_project_id)
  end
  
  def show
    @network = services.network.network(params[:id])
    @subnets = services.network.subnets(@network.id)
    @ports   = services.network.ports(@network.id)
  end
  
  def new
    @network = services.network.network
  end
  
  def create
    @network = services.network.network
    
    network_params = params[@network.model_name.param_key]
    subnets_params = network_params.delete(:subnets)
    
    @network.attributes = network_params 
    
    if @network.save
      
      if subnets_params
        subnet = services.network.subnet 
        subnet.attributes = subnets_params.merge("network_id"=>@network.id)
        puts subnet.pretty_attributes
        subnet.save
      end
      
      flash[:notice] = "Network successfully created."
      redirect_to networks_path
    else
      render action: :new
    end
  end
  
  def edit
    @network = services.network.network(params[:id])
  end
  
  def update
    @network = services.network.network(params[:id])
    @network.attributes = params[@network.model_name.param_key]
    if @network.save
      flash[:notice] = "Network successfully updated."
      redirect_to networks_path
    else
      render action: :edit
    end
  end
  
  def destroy
    @network = services.network.network(params[:id]) rescue nil
        
    if @network
      if @network.destroy
        flash[:notice] = "Network successfully deleted."
      else
        flash[:error] = network.errors.full_messages.to_sentence #"Something when wrong when trying to delete the project"
      end
    end
    
    respond_to do |format|
      format.js {}
      format.html {redirect_to networks_path}
    end    
  end
end
