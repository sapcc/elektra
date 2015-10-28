module Core
  # This class implements functionality to support modal views.
  # All subclasses which require modal views should inherit from this class.
  class ApplicationController < ActionController::Base
    layout 'layouts/core/application'
    
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    helper_method :modal?
    
    def modal?
      if @modal.nil?
        @modal = (request.xhr? and params[:modal]) ? true : false
      end
      @modal
    end

    def render(*args)
      options = args.extract_options!    

      if modal?
        # use modal layout
        options.merge! layout: "/layouts/core/modal" 
      else
        # use current layout
        current_layout = _layout
        current_layout = '/layouts/core/application' if current_layout=='application'
        options.merge! layout: current_layout
      end
      super *args, options
    end

    def redirect_to(options)
      if modal?
        head :ok, location: url_for(options)
      else
        super options
      end
    end

  end
end