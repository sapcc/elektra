class PagesController < ActionController::Base
  include HighVoltage::StaticPage

  layout 'noscope'

end
