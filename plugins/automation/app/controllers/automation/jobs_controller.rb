module Automation
  class JobsController < ::Automation::ApplicationController
    authorization_context 'automation'
    authorization_required

    def show
      @job = services.automation.job(params[:id])

      # get node name
      @node = begin
        services.automation.node(@job.to, ['hostname'])
      rescue ArcClient::ApiError => exception
        if exception.code == 404
          nil
        else
          raise exception
        end
      end

      # payload truncation
      @truncated_payload = ::Automation::DataTruncation.new(@job.payload)

      # log truncation
      log =  begin
        services.automation.job_log(params[:id])
      rescue ArcClient::ApiError => exception
        if exception.code == 404
          nil
        else
          raise exception
        end
      end
      @truncated_log = ::Automation::DataTruncation.new(log)
    end

    def show_data
      @job_id = params[:id]
      @attr = params[:attr]

      if params[:attr] == 'payload'
        @data = begin
          job = services.automation.job(@job_id)
          data = job.payload
          prettify(data)
        rescue ArcClient::ApiError => exception
          if exception.code == 404
            ::Automation::DataTruncation::NO_DATA_FOUND
          else
            raise exception
          end
        end
      elsif params[:attr] == 'log'
        @data =  begin
          data = services.automation.job_log(@job_id)
          prettify(data)
        rescue ArcClient::ApiError => exception
          if exception.code == 404
            ::Automation::DataTruncation::NO_DATA_FOUND
          else
            raise exception
          end
        end
      end

      render layout: 'automation/ansi_app'
    end

    private

    def prettify(data)
      json = JSON.parse(data)
      JSON.pretty_generate(json)
    rescue JSON::ParserError
      data
    end
  end
end
