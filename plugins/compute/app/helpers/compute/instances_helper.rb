module Compute
  module InstancesHelper
    
    def grouped_images(images)
      public_images = []
      private_images = []
      images.each do |image|
        if image.visibility=='public'
          public_images << image
        elsif image.visibility=='private'
          private_images << image
        end
      end
      [ ['Public', public_images], ['Private', private_images] ]
    end
    
    def image_label_for_select(image)
      label = "#{image.name}  (Size: #{byte_to_human(image.size)}, Format: #{image.disk_format})"
      label += ". Project: #{project_name(image.owner)}" if image.visibility=='private'
      label
    end
  end
end
