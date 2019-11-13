module Compute
  module InstancesHelper

    def grouped_images(images,bootable_volumes=nil)
      if images.blank?
        [["Couldn't retrieve images. Please try again", []]]
      else

        # prepare images map: { visibility => { hypervisor => [images] } }
        groupd_images_map = images.each_with_object({}) do |image, map|
          next if image.name.nil?
          hypervisor_type = image.hypervisor_type || 'bare metal'
          visibility = image.visibility
          visibility = 'snapshot' if image.image_type == 'snapshot'
          map[visibility] ||= {}
          map[visibility][hypervisor_type] ||= []
          map[visibility][hypervisor_type] << image
        end.sort

        # build an array with labels
        groups = groupd_images_map.each_with_object([]) do |(visibility, hypervisors), container|
          container << [visibility, []]

          hypervisors.each do |hypervisor_type, images|
            images = images.sort_by { |image| [image.name, image.created_at] }
            items = images.collect do |image|
              [
                image_label_for_select(image),
                image.id,
                data: { vmware_ostype: image.vmware_ostype }
              ]
            end

            container << ["--#{hypervisor_type}", items]
          end
        end

        if bootable_volumes
          volume_items = @bootable_volumes.collect do |v| 
            infos = []
            infos << "Size: #{v.size}" if v.size

            format = (v.volume_image_metadata || {}).fetch('disk_format',nil)
            infos << ", Format: #{format}" if format
            infos_string = infos.length>0 ? "(#{infos.join(', ')})" : ''
            ["#{v.name.present? ? v.name : v.id} #{infos_string}", v.id]
          end
          groups.unshift(["--bootable volumes", volume_items])
        end
        groups
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
      result << ['Public', public_flavors.sort_by { |a| [a.ram, a.vcpus] }] if public_flavors.length>0
      result << ['Private', private_flavors.sort_by { |a| [a.ram, a.vcpus] }] if private_flavors.length>0
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
      @project_floating_ips ||= ObjectCache.where(
        project_id: @scoped_project_id, cached_object_type: 'floatingip'
      ).map {|f| Networking::FloatingIp.new(nil,f[:payload])}

      available_floating_ips = @project_floating_ips.collect(&:floating_ip_address)
      instance_floating_ips = instance.floating_ips.collect {|f| f["addr"]}

      if (available_floating_ips & instance_floating_ips).sort != instance_floating_ips.sort
        #p '::::::::::::::::::: REFRESH CACHE ::::::::::::::::::'
        @project_floating_ips = services.networking.project_floating_ips(@scoped_project_id)
      end
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
