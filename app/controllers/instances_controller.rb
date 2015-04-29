class InstancesController < ApplicationController
  authentication_required region: :get_region

  def index
  end

end
