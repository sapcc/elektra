require 'fog/openstack/models/identity_v3/project'

class Forms::Project < Forms::Base
  # available attributes: :id, :domain_id, :description, :enabled, :name, :links, :parent_id
  
  wrapper_for ::Fog::IdentityV3::OpenStack::Project
  
  ignore_attributes :parent_id, :links
  default_values enabled: true
  
  def is_sandbox?
    self.name.end_with? "_sandbox"
  end
end
