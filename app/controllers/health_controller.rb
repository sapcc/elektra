class HealthController < ApplicationController
  def index
    render text: "ok", status: 200, content_type: 'text/plain'
  end
end
