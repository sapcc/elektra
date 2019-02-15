class TestChannel < ApplicationCable::Channel

  def subscribed
    p "::::::::::::::::::::::::::::::::::::::.TestChannel #{params}"
    stream_from "channel_#{params[:room]}"
  end
end
