require 'fog/openstack/models/identity_v3/os_credential'

class Forms::Credential < Forms::Base
  # available attributes: :id, :project_id, :type, :blob, :user_id, :links
  
  wrapper_for ::Fog::Identity::OpenStack::V3::OsCredential  

  ignore_attributes :links
  default_values blob: {}
  
  # callbacks
  # parse blob json
  def after_initialize
    self.blob = JSON.parse(self.blob) if self.blob and self.blob.is_a?(String)
  end
  
  def after_save
    self.blob = JSON.parse(self.blob) if self.blob #and self.blob.is_a?(String)
    return true
  end
  
  # convert blob to json
  def before_save
    self.blob = self.blob.to_json if self.blob
  end

end

