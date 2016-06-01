module CostControl
  class CostCenterController < ObjectStorage::ApplicationController
    authorization_required

    def show
      # TODO
    end

    def update
      # TODO
      redirect_to plugin('cost_control').cost_center_path
    end

  end
end
