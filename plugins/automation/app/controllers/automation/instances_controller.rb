module Automation

  class InstancesController < Automation::ApplicationController
    before_filter :init_automation

    def index
      @instances = services.compute.servers || []
      @instanceAgents = @automation.instanceAgents(current_user.token, @instances)
    end

    def show
      @instance_name = params[:name]
      @facts = @automation.list_agent_facts(current_user.token, params[:id])
    end

    def show_section
      @instances = services.compute.servers || []
      @instanceAgents = @automation.instanceAgents(current_user.token, @instances)
    end

    def init_automation
      @automation = ArcAutomation.new()
    end

  end

end
