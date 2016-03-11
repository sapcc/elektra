module Image
  class OsImagesController < Image::ApplicationController
    def index
      @images = services.image.images
    end

    def show
      @image = services.image.find_image(params[:id])

      properties = @image.attributes.clone
      # TODO: handle display of owner
      known_attributes = %w(name id status visibility protected size container_format disk_format created_at updated_at owner)
      known_attributes.each { |known| properties.delete(known) }
      additional_prooperties = properties.delete('properties')
      properties.merge!(additional_prooperties) if additional_prooperties

      @properties = properties.sort
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
      render text: 'destroy'
    end
  end
end
