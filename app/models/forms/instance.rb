require 'fog/openstack/models/compute/server'

class Forms::Instance < Forms::Base
  # available attributes: 
  # :instance_name, :addresses, :flavor, :host_id, :image, :metadata, :links, :networks
  # :personality,
  # :progress,
  # :accessIPv4,
  # :accessIPv6,
  # :availability_zone,
  # :user_data_encoded,
  # :state,
  # :created,
  # :updated,
  # :tenant_id,
  # :user_id,
  # :key_name,
  # :fault,
  # :config_drive,
  # :os_dcf_disk_config
  # :os_ext_srv_attr_host
  # :os_ext_srv_attr_hypervisor_hostname
  # :os_ext_srv_attr_instance_name
  # :os_ext_sts_power_state
  # :os_ext_sts_task_state
  # :os_ext_sts_vm_state

  
  wrapper_for ::Fog::Compute::OpenStack::Server
  
  additional_attributes :flavor_ref, :image_ref, :max_count, :nics
  default_values min_count: 1, max_count: 1
  
  def before_save
    self.image_ref = image
    self.flavor_ref = flavor.to_i
    self.max_count = self.max_count.to_i
  end
  
     
end
