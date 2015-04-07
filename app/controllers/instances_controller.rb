class InstancesController < ApplicationController
  authentication_required region: -> c {"europe"}


  def index
  end
end
