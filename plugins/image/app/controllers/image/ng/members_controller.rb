module Image
  module Ng
    class MembersController < ::Image::ApplicationController
      def index
        render json: { members: services.image.members(params[:image_id]) }
      end

      def destroy
      end
    end
  end
end
