module CostControl
  class CostObjectController < ObjectStorage::ApplicationController
    authorization_required

    def show
      # TODO
    end

    def update
      # TODO
      redirect_to plugin('cost_control').cost_object_path
    end

  end
end
