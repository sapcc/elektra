module ServiceUser
  def self.included(base)
    base.send :before_filter, :load_service_user
    base.send :helper_method, :service_user
  end
  
  def load_service_user
    # search in friendly_ids
    @service_user = Core::ServiceUser::Base.load({
      scope_domain: params[:domain_id],
      user_id: Rails.application.config.service_user_id, #'u-monsooncc_admin',
      password: Rails.application.config.service_user_password, #'secret',
      user_domain: Rails.application.config.service_user_domain_name 
    })
    
    # create friendly id entry
  end
  
  def service_user
    @service_user
  end
  
end