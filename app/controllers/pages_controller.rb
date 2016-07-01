class PagesController < ActionController::Base
  include HighVoltage::StaticPage

  layout 'noscope'
  helper_method :current_region

  private

  def current_region
    ENV['MONSOON_DASHBOARD_REGION'] || 'eu-de-1'
  end

end
