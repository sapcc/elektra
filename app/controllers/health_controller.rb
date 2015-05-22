class HealthController < ApplicationController
  def show 
    render text: "ok", status: 200, content_type: 'text/plain'
  end
end
