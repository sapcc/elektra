module Automation

  class JobsController < ::Automation::ApplicationController
    LINES_TRUNCATION = 25
    NO_LOG_FOUND = 'No log available.'
    NO_PAYLOAD_FOUND = 'No payload available.'

    def show
      @job = services.automation.job(params[:id])

      # get node name
      @node = begin
        services.automation.node(@job.to, ['hostname'])
      rescue RubyArcClient::ApiError => exception
        if exception.code == 404
          nil
        else
          raise exception
        end
      end


      # payload
      @payload_lines = 1
      @payload_truncated = false
      @payload_output = NO_PAYLOAD_FOUND
      unless @job.payload.blank?
        @payload_lines = @job.payload.lines.count
        @payload_truncated = @payload_lines > LINES_TRUNCATION
        @payload_output = @job.payload.lines.last(LINES_TRUNCATION).join
      end

      # log
      @log_lines = 1
      @log_truncated = false
      @log_output = NO_LOG_FOUND
      log =  begin
        services.automation.job_log(params[:id])
      rescue RubyArcClient::ApiError => exception
        if exception.code == 404
          nil
        else
          raise exception
        end
      end


      unless log.blank?
        @log_lines = log.lines.count
        @log_truncated = @log_lines > LINES_TRUNCATION
        @log_output = log.lines.last(LINES_TRUNCATION).join
      end
    end


    def show_data
      @job_id = params[:id]
      @attr = params[:attr]

      if params[:attr] == 'payload'
        @data = begin
          job = services.automation.job(@job_id)
          job.payload
        rescue RubyArcClient::ApiError => exception
          if exception.code == 404
            NO_PAYLOAD_FOUND
          else
            raise exception
          end
        end
      elsif params[:attr] == 'log'
        @data =  begin
          services.automation.job_log(@job_id)
        rescue RubyArcClient::ApiError => exception
          if exception.code == 404
            NO_LOG_FOUND
          else
            raise exception
          end
        end
      end

      render :layout => false
    end

  end

end