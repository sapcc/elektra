module Core
  module Error
    class ServiceUserNotAuthenticated < StandardError; end
    class DomainNotFound < StandardError; end
    class ProjectNotFound < StandardError; end
  end
end