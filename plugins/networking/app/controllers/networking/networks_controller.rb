module Networking
  class NetworksController < DashboardController
    before_filter :load_type
    def index
      @networks = services.networking.networks('router:external' => @network_type == 'external')
    end

    def show
      @network = services.networking.network(params[:id])
      @subnets = services.networking.subnets(network_id: @network.id)
      @ports   = services.networking.ports(network_id: @network.id)
    end

    def new
      @network = services.networking.network
    end

    def create
      @network = services.networking.network

      network_params = params[@network.model_name.param_key]
      subnets_params = network_params.delete(:subnets)

      @network.attributes = network_params

      if @network.save

        if subnets_params
          subnet = services.networking.subnet
          subnet.attributes = subnets_params.merge("network_id"=>@network.id)
          puts subnet.pretty_attributes
          subnet.save
        end

        flash[:notice] = "Network successfully created."
        redirect_to plugin('networking').send("networks_#{@network_type}_index_path")
      else
        flash.now[:error] = @network.errors.full_messages.to_sentence
        render action: :new
      end
    end

    def edit
      @network = services.networking.network(params[:id])
    end

    def access_control
      @rbacs = services.networking.rbacs(object_id: params[:network_id], object_type: 'network')
    end

    def update
      @network = services.networking.network(params[:id])
      @network.attributes = params[@network.model_name.param_key]
      if @network.save
        flash[:notice] = 'Network successfully updated.'
        redirect_to plugin('networking').send("networks_#{@network_type}_index_path")
      else
        render action: :edit
      end
    end

    def destroy
      @network = services.networking.network(params[:id]) rescue nil

      if @network
        if @network.destroy
          flash[:notice] = 'Network successfully deleted.'
        else
          flash[:error] = network.errors.full_messages.to_sentence #"Something when wrong when trying to delete the project"
        end
      end

      respond_to do |format|
        format.js {}
        format.html { redirect_to plugin('networking').send("networks_#{@network_type}_index_path") }
      end
    end

    private

    def load_type
      raise 'has to be implemented in subclass'
    end
  end
end
