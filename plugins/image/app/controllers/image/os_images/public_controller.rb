module Image
  class OsImages::PublicController < OsImagesController
    def unpublish
      @image = services.image.new_image
      @image.id = params[:public_id]
      @image.unpublish
    end

    protected

    def filter_params
      { sort_key: 'name', visibility: 'public' }
    end
  end
end
