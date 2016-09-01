module Image
  module OsImages
    module Private
      class MembersController < Image::ApplicationController
      
        def index
          @members = services.image.members(params[:private_id])
        end
      
        def create
          @image = services.image.find_image(params[:private_id])
          @member = services.image.new_member(params[:member])
      
          @project = service_user.find_project_by_name_or_id(@member.member_id) 

          if @project.nil?
            @error = "Could not find project #{@member.member_id}"
          else
            begin 
              @member = services.image.add_member_to_image(@image.id, @project.id) 
            rescue => e
              @error = Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).join(', ')
            end
          end
        end
      
        def destroy
          @success = services.image.remove_member_from_image(params[:private_id],params[:id])
        end
      
      end
    end
  end
end