module CostControl
  class CostObjectController < ObjectStorage::ApplicationController
    authorization_required

    before_filter :load_project_metadata

    def show
    end

    def update
      attrs = params.require(:project_metadata).permit(:cost_object)
      if @metadata.update_attributes(attrs)
        redirect_to plugin('cost_control').cost_object_path
      else
        render action: 'show'
      end
    end

    private

    def load_project_metadata
      @metadata = services.cost_control.find_project_metadata(@scoped_project_id)
      # ensure that the billing service has the correct project and domain name
      # (this is sadly a bit unwieldy because Core::ServiceLayer::Model does
      # not have a changed? method)
      changed = false
      if @metadata.project_name != @scoped_project_name
        @metadata.project_name = @scoped_project_name
        changed = true
      end
      if @metadata.domain_name != @scoped_domain_name
        @metadata.domain_name = @scoped_domain_name
        changed = true
      end
      @metadata.save if changed
    end

  end
end
