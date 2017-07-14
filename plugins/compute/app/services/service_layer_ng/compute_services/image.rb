# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module Image

      def image(image_id, use_cache = false)
        debug "[compute-service][Image] -> image -> GET /images/#{image_id}"

        image_data = nil
        unless use_cache
          image_data = api.compute.show_image_details(image_id).data
          Rails.cache.write("server_image_#{image_id}", image_data, expires_in: 24.hours)
        else
          image_data = Rails.cache.fetch("server_image_#{image_id}", expires_in: 24.hours) do
            api.compute.show_image_details(image_id).data
          end
        end

        return nil if image_data.nil?
        map_to(Compute::Image image_data)
      end
    end
  end
end
