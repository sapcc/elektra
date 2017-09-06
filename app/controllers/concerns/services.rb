# this module is included in controllers.
# the controller should respond_to current_user (monsoon-openstack-auth gem)
module Services
  def self.included(base)
    base.send :helper_method, :services#, :current_region
  end

  # load services provider
  def services(region=current_region)
    # initialize services unless already initialized
    @services ||= Core::ServiceLayer::ServicesManager.new(region)
    # update current_user
    @services.service_user = service_user
    @services.current_user = current_user
    @services.services_ng = services_ng
    @services
  end
end
