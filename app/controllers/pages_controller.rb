class PagesController < ScopeController
  include HighVoltage::StaticPage

  include Services
  include ServiceUser

end
