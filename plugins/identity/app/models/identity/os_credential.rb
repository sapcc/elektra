module Identity
  class OsCredential < Core::ServiceLayer::Model
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
  
    def blob
      value = read("blob")
      if value
        value.is_a?(String) ? JSON.parse(value) : value
      else
        {}
      end
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
  
      if ssh_key?
        begin
          public_key = blob_values["public_key"]
          # try to sanitize the key material first to strip any whitespace and/or linefeeds
          key_parts = public_key.split
          errors.add :public_key, 'The key format is corrupt. It should contain at least a ssh encryption type and a public key.' if key_parts.size < 2
          public_key = key_parts.join(' ')
          Net::SSH::KeyFactory.load_data_public_key(public_key)
        rescue NotImplementedError => e
          puts e
          errors.add :public_key, "The key is not a valid ssh public key. Please check the formatting and remove any linebreaks"
        rescue Net::SSH::Exception => e
          puts e
          errors.add :public_key, "The key is not a valid ssh public key."
        rescue => e
          puts e
          errors.add :public_key, "The key is not a valid ssh public key."
        end
      end
    end

    def ec2?
      type=='ec2'
    end

    def ssh_key?
      type=='ssh-key'
    end
  end
end