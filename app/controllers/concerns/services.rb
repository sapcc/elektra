# this module is included in controllers.
# the controller should respond_to current_user (monsoon-openstack-auth gem)
module Services
  def self.included(base)
    base.send :helper_method, :services, :current_region
  end

  # load services provider
  def services(region=current_region)
    # initialize services unless already initialized
    @services ||= Core::ServiceLayer::ServicesManager.new(region)  
    # update current_user
    @services.service_user = service_user rescue nil
    @services.current_user = current_user 
    @services
  end
  
  # try to find a region based on catalog and default region
  def current_region
    unless @services_current_region
      su = service_user rescue nil
      @services_current_region = ::Core.locate_region(su, Rails.configuration.default_region)
    end
  end
end