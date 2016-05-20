module Image
  class OsImages::PrivateController < OsImagesController
    def access_control
      @members = services.image.members(params[:private_id])
    end

    private

    def load_visibility
      @visibility = 'private'.freeze
    end
  end
end
