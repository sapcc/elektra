# frozen_string_literal: true

module Compute
  # Openstack Flavor Metadata
  class FlavorMetadata < Core::ServiceLayer::Model
    def save
      raise "Do not use save. Use add and remove instead"
    end

    def destroy
      raise "Do not use destroy. Use add and remove instead"
    end

    def update
      raise "Do not use update!"
    end

    # overwrite super attributes method. The default method adds id to the
    # attributes which is not set in metadata
    def attributes
      @attributes
    end

    def add(params)
      rescue_api_errors do
        attrs =
          @service.create_flavor_metadata(
            flavor_id,
            params[:key] => params[:value],
          )
        self.attributes = attrs if attrs
      end
    end

    def remove(key)
      rescue_api_errors { @service.delete_flavor_metadata(flavor_id, key) }
    end
  end
end
