module Automation

  class JobsController < Automation::ApplicationController
    LINES_TRUNCATION = 25

    def index
    end

    def show
      @agent_id = params[:agent_id]
      @job = services.automation.job(params[:id])

      # duration
      time_diff = @job.updated_at.to_time - @job.created_at.to_time
      @duration = Time.at(time_diff.to_i.abs).utc.strftime "%H:%M:%S"

      # payload
      @payload_lines = @job.payload.lines.count
      @payload_truncated = @payload_lines > LINES_TRUNCATION
      @payload_output = @job.payload.lines.last(LINES_TRUNCATION).join

      # log
      log = services.automation.job_log(params[:id]) || ""
      @log_lines = log.lines.count
      @log_truncated = @log_lines > LINES_TRUNCATION
      @log_output = log.lines.last(LINES_TRUNCATION).join
    end


    def show_data
      @job_id = params[:job_id]
      @attr = params[:attr]

      if params[:attr] == 'payload'
        @job = services.automation.job(@job_id)
        @data = @job.payload
      elsif params[:attr] == 'log'
        @data = services.automation.job_log(@job_id)
      end

      render :layout => false
    end

  end

end