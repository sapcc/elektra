# frozen_string_literal: true

#module Identity
  # This class represents the Openstack OS Credential
  # we dont use Keystone credential store anymore
  # # can be deleted later
  # class OsCredential < Core::ServiceLayer::Model
  #   validates :type, presence: { message: 'Please select type' }
  #   validates :project_id, presence: { message: 'Please select project' },
  #                          if: :ec2?
  #   validate :blob_values_valid?

  #   def api_error_name_mapping
  #     super.merge(
  #       'Invalid project-id' => :project_id,
  #       'access_key' => :access,
  #       'access_secret' => :secret
  #     )
  #   end

  #   def blob
  #     value = read('blob')
  #     if value
  #       value.is_a?(String) ? JSON.parse(value) : value
  #     else
  #       {}
  #     end
  #   end

  #   # convert blob to json
  #   def before_save
  #     self.blob = blob.to_json if blob
  #   end

  #   protected

  #   def blob_values_valid?
  #     blob_values = blob.is_a?(String) ? JSON.parse(blob) : blob

  #     errors.add(:access, 'can\'t be blank') if ec2? &&
  #                                               blob_values['access'].blank?
  #     errors.add(:secret, 'can\'t be blank') if ec2? &&
  #                                               blob_values['secret'].blank?

  #     errors.add(:name, 'can\'t be blank') if ssh_key? &&
  #                                             blob_values['name'].blank?
  #     if ssh_key? && blob_values['public_key'].blank?
  #       errors.add(:public_key, 'can\'t be blank')
  #     end

  #     return unless ssh_key?

  #     begin
  #       public_key = blob_values['public_key']
  #       # try to sanitize the key material first to strip any
  #       # whitespace &&/or linefeeds
  #       key_parts = public_key.split
  #       if key_parts.size < 2
  #         errors.add :public_key, 'The key format is corrupt. It should \
  #         contain at least a ssh encryption type && a public key.'
  #       end
  #       public_key = key_parts.join(' ')
  #       Net::SSH::KeyFactory.load_data_public_key(public_key)
  #     rescue NotImplementedError => e
  #       puts e
  #       errors.add :public_key, 'The key is not a valid ssh public key. \
  #       Please check the formatting && remove any linebreaks'
  #     rescue Net::SSH::Exception => e
  #       puts e
  #       errors.add :public_key, 'The key is not a valid ssh public key.'
  #     rescue => e
  #       puts e
  #       errors.add :public_key, 'The key is not a valid ssh public key.'
  #     end
  #   end

  #   def ec2?
  #     type == 'ec2'
  #   end

  #   def ssh_key?
  #     type == 'ssh-key'
  #   end
  # end
#end
