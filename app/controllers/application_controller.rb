class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def get_region
    @region ||= "europe"
  end

  def load_identity_service
    @identity ||= OpenstackService.new(current_user, get_region).identity if current_user
  end


end
