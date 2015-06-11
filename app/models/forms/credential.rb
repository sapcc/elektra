require 'fog/openstack/models/identity_v3/os_credential'

class Forms::Credential < Forms::Base
  # available attributes: :id, :project_id, :type, :blob, :user_id, :links
  
  wrapper_for ::Fog::Identity::OpenStack::V3::OsCredential  

  ignore_attributes :links
  #default_values enabled: true
end
