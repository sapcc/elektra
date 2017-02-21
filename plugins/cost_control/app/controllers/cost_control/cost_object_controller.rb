module CostControl
  class CostObjectController < CostControl::ApplicationController
    authorization_required

    before_filter :load_masterdata, :load_kb11n_billing_objects, :load_billing_objects

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
#########

      if @masterdata.update_attributes(attrs)
        respond_to do |format|
          format.html { redirect_to plugin('cost_control').cost_object_path }
          format.js{}
        end
      else
        respond_to do |format|
          format.html { @scoped_project_id.nil? ? render(action: 'domain_edit') : render(action: 'project_edit') }
          format.js{}
        end
      end
    end

    private

    def load_masterdata
      begin
        if @scoped_project_id
          @masterdata = services.cost_control.find_project_masterdata(@scoped_project_id)
        else
          @masterdata = services.cost_control.find_domain_masterdata(@scoped_domain_id)
        end
      rescue => exception
        if exception.respond_to? :status and exception.status == 401
          raise ::Fog::Billing::ApiError.new("title" => "Only Project- or Domain Administrators can change the Cost Object.", "detail" => "Only Project- or Domain Administrators can change the Cost Object. Please request the project_admin or domain_role .")
        else
          raise ::Fog::Billing::ApiError.new("title" => "No billing data available.", "detail" => "We couldn't retrieve your billing data at this time. Please try again later.")
        end
      end
    end

    def load_kb11n_billing_objects
      begin
        if @scoped_project_id
          @kb11n_billing_objects = services.cost_control.find_kb11n_billing_objects(@scoped_project_id)
        end
      rescue => exception
        raise ::Fog::Billing::ApiError.new("title" => "No billing data available", "detail" => "We couldn't retrieve your billing data at this time. Please try again later.")
      end
    end

    def load_billing_objects
      begin
        if @scoped_project_id
          @billing_objects = services.cost_control.find_billing_objects(@scoped_project_id)
        end
      rescue => exception
        raise ::Fog::Billing::ApiError.new("title" => "No billing data available", "detail" => "We couldn't retrieve your billing data at this time. Please try again later.")
      end
    end

    def experimental
      true
    end

  end
end
