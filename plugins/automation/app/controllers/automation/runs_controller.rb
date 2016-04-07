module Automation

  class RunsController < ::Automation::ApplicationController
    before_action :run, only: [:show, :show_log]
    NO_DATA_FOUND = 'No log available.'
    LINES_TRUNCATION = 25

    def show
      # get the jobs
      list_run_jobs()

      # set the log values
      @log_lines = 1
      @log_truncated = false
      @log_output = NO_DATA_FOUND
      unless @run.log.blank?
        @log_lines = @run.log.lines.count
        @log_truncated = @log_lines > LINES_TRUNCATION
        @log_output = @run.log.lines.last(LINES_TRUNCATION).join
      end
    end

    def show_log
      render :layout => false
    end

    # private

    def run
      @run = services.automation.automation_run(params[:id])
    end

    def list_run_jobs
      @jobs = []
      job_ids = @run.jobs || []
      job_ids.each do |job_id|
        job = begin
          @jobs << services.automation.job(job_id)
        rescue ::RestClient::ResourceNotFound
        end
      end
    end

  end

end