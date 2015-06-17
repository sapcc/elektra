require 'fog/openstack/models/identity_v3/os_credential'

class Forms::Credential < Forms::Base
  # available attributes: :id, :project_id, :type, :blob, :user_id, :links  
  wrapper_for ::Fog::Identity::OpenStack::V3::OsCredential  

  ignore_attributes :links
  default_values blob: {}
  
  validates :type, presence: {message: 'Please select type'}
  validates :project_id, presence: {message: 'Please select project' }, if: :ec2?
  validate :blob_values_valid?
      
  def api_error_name_mapping
    super.merge({
      "Invalid project-id" => :project_id,
      "access_key" => :access,
      "access_secret" => :secret
    })
  end
  
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
  
  protected
  def blob_values_valid?
    blob_values = blob.is_a?(String) ? JSON.parse(blob) : blob

    errors.add(:access, "can't be blank") if ec2? and blob_values["access"].blank?
    errors.add(:secret, "can't be blank") if ec2? and blob_values["secret"].blank?
    
    errors.add(:name, "can't be blank") if ssh_key? and blob_values["name"].blank?
    errors.add(:public_key, "can't be blank") if ssh_key? and blob_values["public_key"].blank?
  end
  
  def ec2?
    type=='ec2'
  end

  def ssh_key?
    type=='ssh-key'
  end
  
end

