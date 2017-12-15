module Image
  class OsImages::PublicController < OsImagesController
    def unpublish
      @image = services_ng.image.unpublish_image(params[:public_id])
      @success = @image and @image.visibility=='private'
    end

    protected
    def filter_params
      {sort_key: 'name', visibility: 'public'}
    end
  end
end
