module Image
  class OsImagesNgController < ::Image::ApplicationController
    def index
      per_page = (params[:per_page] || 15).to_i
      images = paginatable(per_page: per_page) do |pagination_options|
        services.image.images(filter_params.merge(pagination_options))
      end

      render json: { images: images[0..per_page - 1], has_next: images.length > per_page }
    end

    def destroy
    end
  end
end
