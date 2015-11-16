module Automation

  class AutomationController < Automation::ApplicationController
    before_filter :init_automation

    def index
      @instances = services.compute.servers || []
      # @instanceAgents = @automation.instanceAgents(@instances, current_user.token)
      @instanceAgents = @automation.instanceAgentsMock()
    end



    def init_automation
      @automation = Automation::Automation.new()
    end

  end

end
