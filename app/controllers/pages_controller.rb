class PagesController < ActionController::Base
  include HighVoltage::StaticPage

  layout 'noscope'
  helper_method :current_region

  # after_action do
  #   cookies['test-cookie'] = {
  #      :value => 'a yummy cookie',
  #      :expires => 1.year.from_now,
  #      :domain => 'domain.com'
  #    }
  # end

  private

  def current_region
    ENV['MONSOON_DASHBOARD_REGION'] || 'eu-de-1'
  end

end
