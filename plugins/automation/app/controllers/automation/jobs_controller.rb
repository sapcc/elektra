module Automation

  class JobsController < Automation::ApplicationController

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
      @payload_outout = @job.payload.lines.last(25).join

      # log
      log = services.automation.job_log(params[:id]) || ""
      @log_lines = log.lines.count
      @log_output = log.lines.last(25).join
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