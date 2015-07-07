class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  prepend_before_filter do
    if params[:domain_id]
      @domain_id ||= params[:domain_id]
      #@domain ||= services.identity.find_domain(@domain_id)
    end
  end

end
