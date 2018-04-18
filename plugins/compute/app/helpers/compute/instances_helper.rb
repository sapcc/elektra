module Compute
  module InstancesHelper

    def grouped_images(images)
      if images.blank?
        [["Couldn't retrieve images. Please try again", []]]
      else
        public_images = {}
        private_images = {}
        # before sorting delete images that don't have a name
        # if for whatever reason in the future we want to show images without names in the list
        # this needs to be adjusted
        images.delete_if{|image| image.name.nil?}.sort_by!{|image| [image.name, image.created_at]}
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
    end

    def grouped_flavors(flavors)
      public_flavors = []
      private_flavors = []
      flavors.each do |flavor|
        if flavor.public?
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
      label = "#{image.name} (Size: #{byte_to_human(image.size)}, Format: #{image.disk_format}"
      label += !image.buildnumber.blank? ? ", Build: #{image.buildnumber})" : ")"
      label += ". Project: #{project_name(image.owner)}" if owner
      label
    end

    def flavor_label_for_select(flavor)
      "#{flavor.name}  (RAM: #{Core::DataType.new(:bytes, :mega).format(flavor.ram)}, VCPUs: #{flavor.vcpus}, Disk: #{Core::DataType.new(:bytes, :giga).format(flavor.disk)} )"
    end

    def render_image_name(image)
      return '-' if image.blank?
      build_number = image.buildnumber.blank? ? '' : "(#{image.buildnumber})"
      "#{image.name} #{build_number}"
    end


    ########################################################################
    # Floating IPs
    ########################################################################
    def network_ips_map(ips)
      network_ips = ips.each_with_object({}) do |ip_data, map|
        map[ip_data['fixed']['network_name']] ||= []
        map[ip_data['fixed']['network_name']] << ip_data
      end
    end

    def instance_ips(instance)
      @project_floating_ips ||= services.networking.project_floating_ips(
        @scoped_project_id
      )
      instance.ip_maps(@project_floating_ips)
    end

    def render_fixed_floating_ips(ips, options = {})
      capture_haml do
        ips.each do |ip_data|
          fixed = ip_data['fixed']
          floating = ip_data['floating']

          haml_tag :p, class: 'list-group-item-text' do
            haml_tag :span, data: { toggle: 'tooltip' }, title: "Fixed IP (#{fixed['network_name']})" do
              haml_tag :i, '', class: 'fa fa-desktop fa-fw'
              haml_concat fixed['addr']
            end
            if floating
              haml_tag :span, data: { toggle: 'tooltip' }, title: "Floating IP (#{floating['network_name']})" do
                haml_tag(:i, '', class: 'fa fa-arrows-h')
                haml_tag(:i, '', class: 'fa fa-globe fa-fw')
                haml_concat floating['addr']
              end
            end
          end
        end
      end
    end
    #########################################################################
    # End op Floating IPs
    #########################################################################
  end
end
