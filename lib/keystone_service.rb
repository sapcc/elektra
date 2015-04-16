class KeystoneService

  def initialize(region)
    @connection = MonsoonOpenstackAuth.api_client(region).connection_driver
  end



  delegate :user_domains,     to: :@connection
  delegate :domain,           to: :@connection
  delegate :domain_projects,  to: :@connection
  delegate :project,          to: :@connection

end
