module Core
  module Error
    class ServiceUserNotAuthenticated < StandardError; end
    class DomainNotFound < StandardError; end
  end
end