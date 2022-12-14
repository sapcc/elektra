# frozen_string_literal: true

module ServiceLayer
  # This module implements Openstack Compute Image API
  module ComputeServices
    # server snapshots
    module Image
      def image_map
        @image_map ||= class_map_proc(Compute::Image)
      end

      def find_image(image_id, use_cache = false)
        # proxy to image service and cache results
        image_data =
          if use_cache
            Rails
              .cache
              .fetch("server_image_#{image_id}", expires_in: 24.hours) do
                service_manager.image.find_image(image_id).try(:attributes)
              end
          else
            data = service_manager.image.find_image(image_id).try(:attributes)
            Rails.cache.write(
              "server_image_#{image_id}",
              data,
              expires_in: 24.hours,
            )
            data
          end

        return nil if image_data.nil?
        image_map.call(image_data)
      end

      # this is called from server model
      def create_image(server_id, name, metadata = {})
        elektron_compute.post("servers/#{server_id}/action") do
          { "createImage" => { "name" => name, "metadata" => metadata } }
        end
      end
    end
  end
end
