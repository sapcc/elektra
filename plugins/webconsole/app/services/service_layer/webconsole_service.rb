module ServiceLayer

  class WebconsoleService < Core::ServiceLayer::Service

    def available?(action_name_sym=nil)
      current_user.project_id &&
      current_user.token && 
      current_user.service_url("webcli") && 
      current_user.service_url("identity")
    end
  end
end  