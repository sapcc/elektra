module Image
  module Ng
    class ImagesController < ::Image::ApplicationController
      before_action :load_image, only: %i[update_visibility destroy]

      def app; end

      def index

        per_page = (params[:per_page] || 20).to_i
        options = { sort_key: 'name', limit: per_page + 1 }
        options[:marker] = params[:marker] if params[:marker]
        if params[:type] == 'suggested'
          options[:member_status] = 'pending'
          options[:visibility] = 'shared'
        end

        images = services.image.images(options)
        if params[:type] == 'suggested'
          images = images.select { |i| i.owner != @scoped_project_id }
        end

        images = images.map do |image|
          project = FriendlyIdEntry.find_project(@scoped_domain_id, image.owner)
          image.project_name = project.name if project
          image
        end
        
        # byebug
        render json: {
          os_images: images[0..per_page - 1],
          has_next: images.length > per_page
        }
      end

      def show 
        @image = services.image.find_image(params[:id])
        render json: (@image.errors.empty? ? @image : { errors: @image.errors })
      end

      def destroy
        if @image.destroy
          head :no_content
        else
          render json: { errors: @image.errors }
        end
      end

      def update_visibility
        @image.update_visibility(params[:visibility])

        render json: (@image.errors.empty? ? @image : { errors: @image.errors })
      end

      protected

      def load_image
        @image = services.image.new_image
        @image.id = params[:id]
      end
    end
  end
end
