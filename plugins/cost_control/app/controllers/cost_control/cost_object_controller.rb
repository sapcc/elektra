module CostControl
  class CostObjectController < CostControl::ApplicationController
    authorization_required

    before_filter :load_masterdata

    @@retries=0

    def show
      if @scoped_project_id
        render action: 'project_show'
      else
        render action: 'domain_show'
      end
    end

    def edit
      if @scoped_project_id
        render action: 'project_edit'
      else
        render action: 'domain_edit'
      end
    end

    def update
      if @scoped_project_id
        attrs = params.require(:project_masterdata).permit(:cost_object_type, :cost_object_id, :cost_object_inherited)
      else
        attrs = params.require(:domain_masterdata).permit(:cost_object_type, :cost_object_id, :cost_object_responsibleController)
      end

      # normalize "cost_object_inherited" to Boolean
      attrs[:cost_object_inherited] = attrs[:cost_object_inherited] == '1'

      if @masterdata.update_attributes(attrs)
        redirect_to plugin('cost_control').cost_object_path
        return
      else
        ## temp. workaround try again if it failed before
        if @@retries < 2
          @@retries+=1
          @masterdata.update_attributes(attrs)
          redirect_to plugin('cost_control').cost_object_path
          return
        else
          @@retries=0
        end

        if @scoped_project_id
          render action: 'project_edit'
        else
          render action: 'domain_edit'
        end
      end
    end

    private

    def load_masterdata
      if @scoped_project_id
        @masterdata = services.cost_control.find_project_masterdata(@scoped_project_id)
        ## "temp. workaround": try once again if it failed before
        if @masterdata.attributes.empty?
          @masterdata = services.cost_control.find_project_masterdata(@scoped_project_id)
        end
      else
        @masterdata = services.cost_control.find_domain_masterdata(@scoped_domain_id)
        ## "temp. workaround": try once again if it failed before
        if @masterdata.attributes.empty?
          @masterdata = services.cost_control.find_project_masterdata(@scoped_project_id)
        end
      end
    end

  end
end
