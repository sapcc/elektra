require 'fog/openstack/models/identity_v3/project'

class Forms::Project < Forms::Base
  wrapper_for ::Fog::IdentityV3::OpenStack::Project
  
  ignore_attributes :parent_id, :links
  default_values enabled: true
end
