module Automation
  class RunsController < ::Automation::ApplicationController
    authorization_context "automation"
    authorization_required

    before_action :run, only: %i[show show_log]
    NO_DATA_FOUND = "No log available.".freeze
    LINES_TRUNCATION = 25

    def show
      # get the jobs
      list_run_jobs
      @truncated_log = ::Automation::DataTruncation.new(@run.log)
    end

    def show_log
      render layout: false
    end

    # private

    def run
      @run = services.automation.automation_run(params[:id])
    end

    def list_run_jobs
      @jobs = []
      job_ids = @run.jobs || []
      job_ids.each do |job_id|
        job =
          begin
            @jobs << services.automation.job(job_id)
          rescue ArcClient::ApiError => e
            raise e unless e.code == 404
            # do nothing
          end
      end
    end
  end
end
