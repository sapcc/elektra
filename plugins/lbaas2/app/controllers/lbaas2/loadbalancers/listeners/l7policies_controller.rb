module Lbaas2
  module Loadbalancers
    module Listeners
      class L7policiesController < ApplicationController

        def index
          per_page = (params[:per_page] || 9999).to_i
          pagination_options = { sort_key: 'position', sort_dir: 'asc', limit: per_page + 1 }
          pagination_options[:marker] = params[:marker] if params[:marker]
          l7policies = services.lbaas2.l7policies({listener_id: params[:listener_id]}.merge(pagination_options))

          render json: {
            l7policies: l7policies,
            has_next: l7policies.length > per_page
          }
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end

        def show
          l7policy = services.lbaas2.find_l7policy(params[:id])
          render json: {
            l7policy: l7policy
          }
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end  

        def create
          # add project id
          l7PolicyParams = params[:l7policy].merge(project_id: @scoped_project_id, listener_id: params[:listener_id])
          l7policy = services.lbaas2.new_l7policy(l7PolicyParams)
          if l7policy.save
            audit_logger.info(current_user, 'has created', l7policy)
            render json: l7policy
          else
            render json: {errors: l7policy.errors}, status: 422
          end
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end

      end
    end
  end
end