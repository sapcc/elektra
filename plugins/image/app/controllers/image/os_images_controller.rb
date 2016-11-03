module Image
  class OsImagesController < Image::ApplicationController
    # before_filter :load_visibility, only: [:index, :show]

    def index
      @images = paginatable(per_page: 15) do |pagination_options|
        services.image.images(filter_params.merge(pagination_options))
      end
    end

    def show
      @image = services.image.find_image(params[:id])

      properties = @image.attributes.clone.stringify_keys
      known_attributes = %w(name id status visibility protected size container_format disk_format created_at updated_at owner)
      known_attributes.each { |known| properties.delete(known) }
      additional_properties = properties.delete('properties')
      properties.merge!(additional_properties) if additional_properties

      @properties = properties.sort_by { |k, _v| k }
    end

    def new
    end

    def create
      render text: 'create'
    end

    def edit
    end

    def update
      render text: 'update'
    end

    def destroy
      @image = services.image.find_image(params[:id])
      @success =  (@image and @image.destroy)
    end

    protected
    def filter_params
      raise 'has to be implemented in subclass'
    end
  end
end
