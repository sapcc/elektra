module Automation

  class AutomationsController < Automation::ApplicationController

    def index
    end

    def new
      @automation_types = {script: 'Script', chef: 'Chef'}
      @automation = ::Automation::Forms::CreateAutomation.new(run_list: ['a', 'b'])
    end

    def create
    end

  end

end
