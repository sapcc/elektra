module Compute
  module InstancesHelper
    
    # def grouped_images(images)
    #   public_images = []
    #   private_images = []
    #   images.each do |image|
    #     if image.visibility=='public'
    #       public_images << image
    #     elsif image.visibility=='private'
    #       private_images << image
    #     end
    #   end
    #   [ ['Public', public_images], ['Private', private_images] ]
    # end
    
    def grouped_images(images)
      public_images = {}
      private_images = {}
      images.each do |image|
        if image.visibility=='public'
          type = (image.hypervisor_type || 'unknown')
          public_images[type] ||= []
          public_images[type] << image
        elsif image.visibility=='private'
          type = (image.hypervisor_type || 'unknown')
          private_images[type] ||= []
          private_images[type] << image
        end
      end
      result = []
      result << ['Public',public_images.delete('unknown') ||[]]
      public_images.each{|hypervisor,images| result << ["--#{hypervisor}",images]}
      result << ['Private',private_images.delete('unknown') || []]
      private_images.each{|hypervisor,images| result << ["--#{hypervisor}",images]}
      result
    end
    
    def image_label_for_select(image)
      label = "#{image.name} (Size: #{byte_to_human(image.size)}, Format: #{image.disk_format})"
      label += ". Project: #{project_name(image.owner)}" if image.visibility=='private'
      label
    end
  end
end
