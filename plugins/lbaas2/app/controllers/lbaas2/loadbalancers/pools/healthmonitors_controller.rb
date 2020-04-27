module Lbaas2
  module Loadbalancers
    module Pools
      class HealthmonitorsController < ApplicationController

        def show
          healthmonitor = services.lbaas2.find_healthmonitor(@pool.healthmonitor_id)
          render json: {
            healthmonitor: healthmonitor
          }
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end  

      end
    end
  end
end
