module CostControl
  class CostObjectController < ObjectStorage::ApplicationController
    authorization_required

    before_filter :load_project_metadata

    def show
    end

    def update
      attrs = params.require(:project_metadata).permit(:cost_object_type, :cost_object_id)
      if @metadata.update_attributes(attrs)
        redirect_to plugin('cost_control').cost_object_path
      else
        render action: 'show'
      end
    end

    private

    def load_project_metadata
      @metadata = services.cost_control.find_project_metadata(@scoped_project_id)
    end

  end
end
