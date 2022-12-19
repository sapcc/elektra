module Compute
  class FlavorsController < ::DashboardController
    authorization_context "compute"
    authorization_required

    def index
      @flavors =
        services
          .compute
          .flavors({ is_public: "None" })
          .sort_by { |a| [a.ram, a.vcpus] }
    end

    def new
      @flavor = services.compute.new_flavor
    end

    def create
      @flavor = services.compute.new_flavor(params[:flavor])
      if @flavor.save
        respond_to do |format|
          format.html { redirect_to plugin("compute").flavors_url }
          format.js { render action: :create, format: :js }
        end
      else
        render action: :new
      end
    end

    def edit
      @flavor = services.compute.find_flavor(params[:id])
    end

    def update
      @flavor = services.compute.new_flavor(params[:flavor])
      @flavor.id = params[:id]
      if @flavor.save
        respond_to do |format|
          format.html { redirect_to plugin("compute").flavors_url }
          format.js { render action: :update, format: :js }
        end
      else
        render action: :new
      end
    end

    def destroy
      @flavor = services.compute.new_flavor
      @flavor.id = params[:id]
      @error = "Could not delete Flavor" unless @flavor.destroy

      respond_to do |format|
        format.html do
          flash.now[:error] = @error if @error
          redirect_to plugin("compute").flavors_url
        end
        format.js { render action: :destroy, format: :js }
      end
    end
  end
end
