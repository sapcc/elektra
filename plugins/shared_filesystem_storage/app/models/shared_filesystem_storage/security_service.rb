# frozen_string_literal: true

module SharedFilesystemStorage
  # This class implements the sevice security
  class SecurityService < Core::ServiceLayer::Model
    def attributes_for_update
      if status == 'active'
        {
          'name'              => read('name'),
          'description'       => read('description')
        }
      else
        {
          'type'        => read('type'),
          'name'        => read('name'),
          'dns_ip'      => read('dns_ip'),
          'description' => read('description'),
          'user'        => read('user'),
          'password'    => read('password'),
          'domain'      => read('domain'),
          'ou'          => read('ou')
        }
      end.delete_if { |_, v| v.blank? }
    end
  end
end
