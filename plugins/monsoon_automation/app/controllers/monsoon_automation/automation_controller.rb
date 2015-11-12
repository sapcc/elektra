module MonsoonAutomation

  class AutomationController < MonsoonAutomation::ApplicationController
    before_filter :init_automation

    def index
      @instances = services.compute.servers || []
      # @instanceAgents = @automation.instanceAgents(@instances, current_user.token)
      @instanceAgents = @automation.instanceAgentsMock()
    end



    def init_automation
      @automation = MonsoonAutomation::Automation.new()
    end

  end

end
