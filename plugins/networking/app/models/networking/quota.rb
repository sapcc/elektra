# frozen_string_literal: true

module Networking
  # Implements Openstack Port
  class Quota < Core::ServiceLayerNg::Model
    def id
      read('project_id')
    end
  end
end
