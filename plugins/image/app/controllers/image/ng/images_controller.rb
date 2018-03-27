module Image
  module Ng
    class ImagesController < ::Image::ApplicationController
      def app
      end
      def index
        per_page = (params[:per_page] || 10).to_i
        options = { sort_key: 'name', limit: per_page + 1 }
        options[:marker] = params[:marker] if params[:marker]
        if params[:type] == 'suggested'
          options[:member_status] = 'pending'
          options[:visibility] = 'shared'
        end

        images = services.image.images(options)
        render json: {
          os_images: images[0..per_page - 1],
          has_next: images.length > per_page
        }
      end

      def destroy
      end
    end
  end
end
