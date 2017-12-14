# frozen_string_literal: true

module ServiceLayerNg
  module ImageServices
    module Image
      def image_map
        @image_map ||= class_map_proc(::Image::Image)
      end

      # use this with pagination options, otherwise you will get a
      # maxium of 25 images (glance default limit)
      def images(filter = {})
        elektron_images.get('images', filter).map_to('body.images', &image_map)
      end

      def find_image!(id)
        return nil if id.blank?
        elektron_images.get("images/#{id}").map_to('body', &image_map)
      end

      def find_image(id)
        find_image!(id)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      def publish_image(id)
        elektron_images.patch("images/#{id}") do
          [
            {
              op: 'replace',
              path: '/visibility',
              value: 'public'
            }
          ]
        end
      end

      def unpublish_image(id)
        elektron_images.patch("images/#{id}") do
          [
            {
              op: 'replace',
              path: '/visibility',
              value: 'private'
            }
          ]
        end
      end

      ################# INTERFACE METHODS ######################
      def delete_image(id)
        elektron_images.delete("images/#{id}")
      end
    end
  end
end
