require 'active_resource'

module Automation

  class BaseAutomation < ::ActiveResource::Base

    # self.site = "https://localhost/api/v1/"

    class << self
      attr_accessor :api_key
    end

    def save
      prefix_options[:X-Auth-Token] = self.class.api_key
      super
    end

  end

end
