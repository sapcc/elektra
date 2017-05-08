module Compute
  module InstancesHelper

    def grouped_images(images)
      public_images = {}
      private_images = {}
      # before sorting delete images that don't have a name
      # if for whatever reason in the future we want to show images without names in the list
      # this needs to be adjusted
      images.delete_if{|image| image.name.nil?}.sort_by!{|image| image.name}
      images.each do |image|
        if image.visibility=='public'
          type = (image.hypervisor_type || 'no hypervisor type')
          public_images[type] ||= []
          public_images[type] << image
        elsif image.visibility=='private'
          type = (image.hypervisor_type || 'no hypervisor type')
          private_images[type] ||= []
          private_images[type] << image
        end
      end
      result = []
      result << ['Public', []]
      public_images.each{|hypervisor,images| result << ["--#{hypervisor}",images.collect{|image| [image_label_for_select(image), image.id, data: {vmware_ostype: image.vmware_ostype}]} ]}
      result << ['Private', []]
      private_images.each{|hypervisor,images| result << ["--#{hypervisor}",images.collect{|image| [image_label_for_select(image), image.id, data: {vmware_ostype: image.vmware_ostype}]} ]}
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
      owner = image.private ? image.owner : nil
      label = "#{image.name} (Size: #{byte_to_human(image.size)}, Format: #{image.disk_format})"
      label += ". Project: #{project_name(image.owner)}" if owner
      label
    end

    def flavor_label_for_select(flavor)
      "#{flavor.name}  (RAM: #{Core::DataType.new(:bytes, :mega).format(flavor.ram)}, VCPUs: #{flavor.vcpus}, Disk: #{Core::DataType.new(:bytes, :giga).format(flavor.disk)} )"
    end
  end
end
