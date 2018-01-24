module Image
  class OsImages::PrivateController < OsImagesController
    def publish
      @image = services.image.new_image
      @image.id = params[:private_id]
      @image.publish
    end

    protected

    def filter_params
      { sort_key: 'name', visibility: 'private' }
    end
  end
end
