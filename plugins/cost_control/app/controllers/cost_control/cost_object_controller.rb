module CostControl
  class CostObjectController < ObjectStorage::ApplicationController
    authorization_required

    before_filter :load_project_metadata

    def show
      # TODO
    end

    def update
      # TODO
      redirect_to plugin('cost_control').cost_object_path
    end

    private

    def load_project_metadata
      @metadata = services.cost_control.find_project_metadata(@scoped_project_id)
    end

  end
end
