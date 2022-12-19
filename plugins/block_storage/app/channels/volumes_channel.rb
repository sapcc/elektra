class VolumesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "projects:#{params[:project_id]}:volumes"
  end

  def unsubscribed
  end
end
