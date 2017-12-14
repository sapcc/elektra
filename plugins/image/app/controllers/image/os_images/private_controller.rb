module Image
  class OsImages::PrivateController < OsImagesController

    def publish
      @image = services_ng.image.publish_image(params[:private_id])
      @success = @image and @image.visibility=='public'
    end

    protected
    def filter_params
      {sort_key: 'name', visibility: 'private'}
    end
  end
end
