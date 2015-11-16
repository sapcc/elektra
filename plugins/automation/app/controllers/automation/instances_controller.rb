module Automation

  class InstancesController < Automation::ApplicationController
    before_filter :init_automation

    def index
      @instances = services.compute.servers || []
      @instanceAgents = @automation.instanceAgentsMock()
    end

    def show_section
      @instances = services.compute.servers || []
      @instanceAgents = @automation.instanceAgentsMock()
    end

    def init_automation
      @automation = ArcAutomation.new()
    end

  end

end
