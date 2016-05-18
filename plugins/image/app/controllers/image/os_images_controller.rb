module Image
  class OsImagesController < Image::ApplicationController
    def visibility
      raise 'has to be implemented in subclass'
    end

    def index
      images_per_page = 15

      page = params.fetch(:page, 1).to_i
      reverse = params[:previous]

      sort_dir = reverse ? 'desc' : 'asc'

      openstack_params = {
        # retrieve one more to see if something is on the next page
        limit: images_per_page + 1,
        sort_key: 'name',
        sort_dir: sort_dir,
        visibility: visibility
      }
      # first call has no marker
      openstack_params[:marker] = params[:marker] if params[:marker].present?
      current_images = services.image.images(openstack_params)
      current_images_count = current_images.count

      previous_images_count = images_per_page * (page - 1)
      # total_count is dynamic, for that Kaminari displays a 'next page' link or not
      total_count = previous_images_count + current_images_count
      # if we came in from previous page, there is always a next
      total_count += images_per_page if reverse && page == 1

      # remove the extra image if there is one
      current_images.pop if current_images_count > images_per_page
      current_images.reverse! if reverse

      @images = Kaminari.paginate_array(current_images, total_count: total_count).page(page).per(images_per_page)
      @next_marker = @images.last.id  if @images.present?
      @prev_marker = @images.first.id if @images.present?
    end

    def show
      @image = services.image.find_image(params[:id])

      properties = @image.attributes.clone
      # TODO: handle display of owner
      known_attributes = %w(name id status visibility protected size container_format disk_format created_at updated_at owner)
      known_attributes.each { |known| properties.delete(known) }
      additional_properties = properties.delete('properties')
      properties.merge!(additional_properties) if additional_properties

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
