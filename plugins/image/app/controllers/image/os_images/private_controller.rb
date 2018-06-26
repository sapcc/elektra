module Image
  class OsImages::PrivateController < OsImagesController
    def publish
      @image = services.image.new_image
      @image.id = params[:private_id]
      @image.update_visibility('public')
    end

    protected

    def filter_params
      { sort_key: 'name', visibility: 'private' }
    end
  end
end
