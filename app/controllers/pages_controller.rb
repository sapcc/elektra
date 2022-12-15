class PagesController < ActionController::Base
  include HighVoltage::StaticPage

  layout :layout_for_page

  helper_method :current_region, :current_domain

  # after_action do
  #   cookies['test-cookie'] = {
  #      :value => 'a yummy cookie',
  #      :expires => 1.year.from_now,
  #      :domain => 'domain.com'
  #    }
  # end

  private

  def current_region
    ENV["MONSOON_DASHBOARD_REGION"] || "eu-de-1"
  end

  def current_domain
    params[:domain_id]
  end

  def layout_for_page
    case params[:id]
    when "landing"
      "juno-fullscreen"
    else
      "noscope"
    end
  end
end
