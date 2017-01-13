module Compute
  module InstancesHelper

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

    def grouped_flavors(flavors)
      public_flavors = []
      private_flavors = []
      flavors.each do |flavor|
        if flavor.is_public?
          public_flavors << flavor
        else
          private_flavors << flavor
        end
      end
      result = []
      result << ['Public',public_flavors.sort_by{|a| [a.ram, a.vcpus]}] if public_flavors.length>0
      result << ['Private',private_flavors.sort_by{|a| [a.ram, a.vcpus]}] if private_flavors.length>0
      result
    end

    def image_label_for_select(image)
      label = "#{image.name} (Size: #{byte_to_human(image.size)}, Format: #{image.disk_format})"
      label += ". Project: #{project_name(image.owner)}" if image.visibility=='private'
      label
    end

    def flavor_label_for_select(flavor)
      "#{flavor.name}  (RAM: #{Core::DataType.new(:bytes, :mega).format(flavor.ram)}, VCPUs: #{flavor.vcpus}, Disk: #{Core::DataType.new(:bytes, :giga).format(flavor.disk)} )"
    end
  end
end
