module Lbaas2
  module Loadbalancers
    module Pools
      class MembersController < ApplicationController

        def index
          members = services.lbaas2.members(params[:pool_id])
          render json: {
            members: members
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