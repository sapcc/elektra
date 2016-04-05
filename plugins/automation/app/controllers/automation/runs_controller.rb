module Automation

  class RunsController < ::Automation::ApplicationController
    before_action :run, only: [:show, :show_log]
    NO_DATA_FOUND = 'No log available.'
    LINES_TRUNCATION = 25

    def show
      @log_lines = 1
      @log_truncated = false
      @log_output = NO_DATA_FOUND

      unless @run.log.blank?
        @log_lines = @run.log.lines.count
        @log_truncated = @log_lines > LINES_TRUNCATION
        @log_output = @run.log.lines.last(LINES_TRUNCATION).join
      end

      # if params[:partial]
      #   respond_to do |format|
      #     format.js {
      #       render partial: 'show.js'
      #     }
      #     return
      #   end
      # end
    end

    def show_log
      render :layout => false
    end

    # private

    def run
      @run = services.automation.automation_run(params[:id])
    end

  end

end