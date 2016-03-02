module Automation

  class AutomationsController < Automation::ApplicationController

    def index
    end

    def new
      @automation_types = {script: 'Script', chef: 'Chef'}
      @automation = ::Automation::Forms::CreateAutomation.new()
    end

    def create
    end

  end

end
