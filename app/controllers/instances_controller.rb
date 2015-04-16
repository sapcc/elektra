class InstancesController < ApplicationController
  authentication_required region: :get_region
  before_filter :load_keystone_service, :load_identity_service


  def index
  end


  private

  def load_keystone_service
    @auth_service = KeystoneService.new(@region)
  end
end
