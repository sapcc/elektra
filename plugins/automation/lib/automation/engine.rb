module Automation
  class Engine < ::Rails::Engine
    isolate_namespace Automation

    initializer 'automation.init_logger' do |app|
      ActiveResource::Base.logger = Logger.new(STDERR)
    end
  end
end
