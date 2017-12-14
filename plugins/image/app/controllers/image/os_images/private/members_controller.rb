# frozen_string_literal: true

module Image
  module OsImages
    module Private
      # Implements Image members
      class MembersController < Image::ApplicationController
        def index
          @image = services_ng.image.find_image(params[:private_id])
          @members = services_ng.image.members(params[:private_id])
        end

        def create
          @image = services_ng.image.find_image(params[:private_id])
          @member = services_ng.image.new_member(params[:member])

          @project = service_user.identity.find_project_by_name_or_id(
            @scoped_domain_id, @member.member_id
          )

          if @project.nil?
            @error = "Could not find project #{@member.member_id}"
          else
            begin
              @member = services_ng.image.add_member_to_image(@image.id, @project.id)
            rescue => e
              @error = Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).join(', ')
            end
          end
        end

        def destroy
          @success = services_ng.image.remove_member_from_image(params[:private_id],params[:id])
        end
      end
    end
  end
end
