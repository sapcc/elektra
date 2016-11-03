module Automation

  class Job < ArcClient::Job

    def self.create_jobs(_jobs=[])
      jobs = []
      _jobs.data.each do |_job|
        job = Job.new(_job)
        jobs << job
      end
      {elements: jobs, total_elements: _jobs.pagination.total_elements}
    end

    def duration
      time_diff = self.updated_at.to_time - self.created_at.to_time
      Time.at(time_diff.to_i.abs).utc.strftime "%H:%M:%S"
    end

    def owner_name
      if self.user.name.nil?
        return self.user.id
      else
        return self.user.name
      end
    end

  end

end