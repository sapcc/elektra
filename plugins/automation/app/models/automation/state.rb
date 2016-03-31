module Automation

  module State
    MISSING = '-'
    IP_MISSING = '-'

    module Agent
      ONLINE = true
      OFFLINE = false
    end

    module Job
      QUEUED = 'queued'
      EXECUTING = 'executing'
      FAILED = 'failed'
      COMPLETED = 'complete'
    end

    module Run
      PREPARING = 'preparing'
      EXECUTING = 'executing'
      FAILED = 'failed'
      COMPLETED = 'completed'
    end

  end

end
