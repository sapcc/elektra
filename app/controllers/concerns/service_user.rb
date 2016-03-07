module ServiceUser
  def self.included(base)
    base.send :helper_method, :service_user
  end

  def service_user
    @service_user ||= Core::ServiceUser::Base.load({
      scope_domain: (params[:domain_id] || Rails.configuration.default_domain),
      user_id: Rails.application.config.service_user_id, #'u-monsooncc_admin',
      password: Rails.application.config.service_user_password, #'secret',
      user_domain: Rails.application.config.service_user_domain_name 
    })
  end
  
end