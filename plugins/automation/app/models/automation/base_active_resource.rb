require 'active_resource'
require 'active_resource_response'

module Automation

  class BaseActiveResource < ActiveResource::Base
    include ::Automation::Helpers
    add_response_method :http_response

    cattr_accessor :static_headers
    self.static_headers = headers

    class << self
      attr_accessor :token
    end

    def self.headers
      new_headers = static_headers.clone
      unless self.token.blank?
        new_headers['X-Auth-Token'] = self.token
      end
      new_headers
    end

  end

end
