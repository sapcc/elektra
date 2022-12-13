class HealthController < ActionController::Base
  def liveliness
    render plain: "Alive!"
  end
  def readiness
    FriendlyIdEntry.count
    render plain: "OK"
  end
end
