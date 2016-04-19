module CurrentUserWrapper
  # Redefine current_user method which comes from monsoon_openstack_auth gem.
  # This method wraps current_user and adds some details like email and full_name.
  def current_user
    return nil if super.nil?
    return @current_user_wrapper if @current_user_wrapper and @current_user_wrapper.token==super.token
    @current_user_wrapper = CurrentUserWrapper.new(super,session,service_user)
  end

  # Wrapper for current user
  class CurrentUserWrapper
    attr_reader :current_user
    def initialize(current_user, session, service_user)
      @current_user = current_user
      @session      = session
      @service_user = service_user
      # already saved user details in session
      old_user_details = (@session[:current_user_details] || {})
      
      # check if user id from session differs from current_user id
      if old_user_details["id"]!=current_user.id
        # load user details for current_user
        
        new_user_details = @service_user.find_user(current_user.id) rescue nil
        # save user_details in session
        @session[:current_user_details] = new_user_details.nil? ? {} : new_user_details.attributes.merge("id"=>new_user_details.id)
      end
    end

    def try(method_name)
      if self.respond_to?(method_name)
        super(method_name)
      else
        @current_user.try(method_name)
      end
    end
  
    # delegate all methods to wrapped current user  
    def method_missing(name, *args, &block)
      @current_user.send(name,*args,&block)
    end

    # Email is not provided by current_user. So add it here.
    def email
      @session[:current_user_details]["email"] if @session[:current_user_details]
    end
  
    # Fullname is not provided by current_user. So add it here.
    def full_name
      @session[:current_user_details]["description"] if @session[:current_user_details]
    end
  end
end
