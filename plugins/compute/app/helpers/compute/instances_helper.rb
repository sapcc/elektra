# frozen_string_literal: true

module Compute
  module InstancesHelper
    # IMAGES
    # handle image data
    # array of hashes
    # {
    #  'git_branch' => 'master',
    #  'hw_vif_model' => 'VirtualVmxnet3',
    #  'vmware_adaptertype' => 'paraVirtual',
    #  'vmware_disktype' => 'streamOptimized',
    #  'name' => 'flatcar-stable-amd64',
    #  'disk_format' => 'vmdk',
    #  'container_format' => 'bare',
    #  'visibility' => 'public',
    #  'size' => 523_169_280,
    #  'virtual_size' => nil,
    #  'status' => 'active',
    #  'checksum' => '7f5d6771136f689aff643b78ac04af70',
    #  'protected' => false,
    #  'min_ram' => 2032,
    #  'min_disk' => 10,
    #  'owner' => 'caa6209d2c38450f8266311fd0f05446',
    #  'os_hidden' => false,
    #  'os_hash_algo' => 'sha512',
    #  'os_hash_value' => 'ad7946fc3a621f9cab8e867038d234f4af18ca239866304efe51d5ef20cf9ee092b5fffb85436bea7c176a2a8eb4c5e477ce6b5b41ca2a3aef1f9a178841690c',
    #  'created_at' => '2020-05-28T13:49:31Z',
    #  'updated_at' => '2020-05-28T13:49:47Z',
    #  'direct_url' => 'swift+https://objectstore-3.eu-de-1.cloud.sap:443/v1/AUTH_caa6209d2c38450f8266311fd0f05446/XXXXXXX',
    #  'file' => '/v2/images/cd116ba4-3d20-4011-adb9-f86d821b5e8f/file',
    #  'schema' => '/v2/schemas/image',
    #  'cached_object_type' => 'image',
    #  'project_id' => nil,
    #  'search_label' => 'owner: caa6209d2c38450f8266311fd0f05446',
    #  'id' => 'cd116ba4-3d20-4011-adb9-f86d821b5e8f'
    # }

    def grouped_images(images, bootable_volumes = nil, hv_type)
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

            if hv_type == hypervisor_type || hv_type == 'all'
              container << ["--#{hypervisor_type}", items]
            end
          end
        end

        # [
        #  ["public", []],
        #  ["--baremetal",
        #    [
        #      [
        #        "coreos-alpha-amd64 (Size: 491.79MB, Format: vmdk)",
        #        "2bbf65c4-9030-4d90-a69c-f00c226478c5",
        #        {:data=>{:vmware_ostype=>nil}}
        #      ],
        #      []
        #    ]
        #  ]
        # ]
     
        if hv_type == "vmware"
          if bootable_volumes && !bootable_volumes.empty?
            volume_items = @bootable_volumes.collect do |v|
              infos = []
              infos << "Size: #{v.size}GB" if v.size

              format = (v.volume_image_metadata || {}).fetch('disk_format', nil)
              infos << "Format: #{format}" if format
              infos_string = !infos.empty? ? "(#{infos.join(', ')})" : ''
              ["#{v.name.present? ? v.name : v.id} #{infos_string}", v.id]
            end
            groups.unshift(['--bootable volumes', volume_items])
          end
        end
        groups
      end
    end

    def js_images_data(images)
      js_data = []
      unless images.empty?
        js_data = images.map do |flavor|
          { flavor.id => {
            'name' => flavor.name,
            'ram' => flavor.ram,
            'vcpus' => flavor.vcpus,
            'disk' => flavor.disk
          } }
        end
      end

      js_data.to_json
    end

    def image_label_for_select(image)
      owner = image.private ? image.owner : nil
      label = "#{image.name} (Size: #{byte_to_human(image.size)}, Format: #{image.disk_format}"
      label += !image.buildnumber.blank? ? ", Build: #{image.buildnumber})" : ')'
      label += ". Project: #{project_name(image.owner)}" if owner
      label
    end

    def render_image_name(image)
      return '-' if image.blank?

      build_number = image.buildnumber.blank? ? '' : "(#{image.buildnumber})"
      "#{image.name} #{build_number}"
    end

    # FLAVOR
    # array of hashes
    # {
    #  "name"=>"m2.4xlarge",
    #  "links"=>[
    #    {"href"=>"https://compute-3.eu-de-1.cloud.sap:443/v2.1/flavors/140", "rel"=>"self"},
    #    {"href"=>"https://compute-3.eu-de-1.cloud.sap:443/flavors/140",
    #    "rel"=>"bookmark"}
    #  ],
    #  "ram"=>65520,
    #  "OS-FLV-DISABLED:disabled"=>false,
    #  "vcpus"=>8,
    #  "swap"=>"",
    #  "os-flavor-access:is_public"=>true,
    #  "rxtx_factor"=>1.0,
    #  "OS-FLV-EXT-DATA:ephemeral"=>0,
    #  "disk"=>64,
    #  "description"=>nil,
    #  "cached_object_type"=>"flavor",
    #  "project_id"=>nil,
    #  "search_label"=>"",
    #  "id"=>"140"
    # }
    # handle flavor data
    def grouped_flavors(flavors)
      public_flavors_vmware = []
      public_flavors_baremetal = []
      private_flavors = []
      flavors.each do |flavor|
        if flavor.public?
          if flavor.name =~ /^baremetal/ || flavor.name =~ /^zh/
            public_flavors_baremetal << flavor
          else
            public_flavors_vmware << flavor
          end
        else
          private_flavors << flavor
        end
      end

      # group to public and private
      result = [['public', []]]
      unless public_flavors_baremetal.empty?
        result << ['--bare metal',public_flavors_baremetal.sort_by { |a| [a.ram, a.vcpus] }]
      end
      unless public_flavors_vmware.empty?
        result << ['--vmware',public_flavors_vmware.sort_by { |a| [a.ram, a.vcpus] }]
      end
      unless private_flavors.empty?
        result << ['private', private_flavors.sort_by { |a| [a.ram, a.vcpus] }]
      end
      result
    end

    def js_flavor_data(flavors)
      js_data = []
      unless flavors.empty?
        js_data = flavors.map do |flavor|
          { flavor.id => {
            'name' => flavor.name,
            'ram' => flavor.ram,
            'vcpus' => flavor.vcpus,
            'disk' => flavor.disk
          } }
        end
      end

      js_data.to_json
    end

    # flavor label in dropdown
    def flavor_label_for_select(flavor)
      "#{flavor.name}  (RAM: #{Core::DataType.new(:bytes, :mega).format(flavor.ram)}, VCPUs: #{flavor.vcpus}, Disk: #{Core::DataType.new(:bytes, :giga).format(flavor.disk)} )"
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
      ).map { |f| Networking::FloatingIp.new(nil, f[:payload]) }

      available_floating_ips = @project_floating_ips.collect(&:floating_ip_address)
      instance_floating_ips = instance.floating_ips.collect { |f| f['addr'] }

      if (available_floating_ips & instance_floating_ips).sort != instance_floating_ips.sort
        # p '::::::::::::::::::: REFRESH CACHE ::::::::::::::::::'
        @project_floating_ips = services.networking.project_floating_ips(@scoped_project_id)
      end
      instance.ip_maps(@project_floating_ips)
    end

    def render_fixed_floating_ips(ips)
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
