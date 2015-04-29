class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  include OpenstackServiceProvider::Services


  def get_region
    @region ||= "europe"
  end

end
