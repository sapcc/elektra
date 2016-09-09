module Compute
  module Flavors
    class MembersController < Image::ApplicationController
    
      def index
        @flavor = services.compute.flavor(params[:flavor_id])
        @members = services.compute.flavor_members(params[:flavor_id])
      end
    
      def create
        @member = services.compute.new_flavor_access(params[:member])
        @member.flavor_id = params[:flavor_id]
        @project = services.identity.find_project(@member.tenant_id.strip) 

        if @project.nil?
          @error = "Could not find project #{@member.tenant_id}"
        else
          begin 
            @member = services.compute.add_flavor_access_to_tenant(@member.flavor_id,@member.tenant_id) 
            @member = @member.first if @member and @member.is_a?(Array)
          rescue => e
            @error = Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).join(', ')
          end
        end
      end
    
      def destroy
        @success = services.compute.remove_flavor_access_from_tenant(params[:flavor_id],params[:id])
      end
    
    end
  end
end