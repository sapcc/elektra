module Image
  class OsImages::PrivateController < OsImagesController
    def access_control
      @members = services.image.members(params[:private_id])
    end
    
    def new_member
      @image = services.image.find_image(params[:private_id])
      @member = services.image.new_member
    end
    
    def add_member
      @image = services.image.find_image(params[:private_id])
      @member = services.image.new_member(params[:member])
      
      @project = service_user.find_project_by_name_or_id(@member.project) 

      if @project.nil?
        @error = "Could not find project #{project_name_or_id}"
      else
        begin 
          services.image.add_member_to_image(@image.id, @project.id) 
        rescue => e
          @error = Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).join(', ')
        end
      end
      
      if @error
        render action: :new_member and return
      end
    end

    protected
    def filter_params
      {sort_key: 'name', visibility: 'private', owner: @scoped_project_id}
    end
  end
end
