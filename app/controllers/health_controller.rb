class HealthController < ActionController::Base
  def liveliness
    render plain: "Alive!"
  end

  def readiness
    FriendlyIdEntry.count
    render plain: "OK"
  end

  def startprobe
    # check connection with the db
    FriendlyIdEntry.count
    # render similar layout as our application with all general JS (not specific from the a plugin)
    @startProbeText = 'This is the start probe'
    render layout: 'health'
  end
end
