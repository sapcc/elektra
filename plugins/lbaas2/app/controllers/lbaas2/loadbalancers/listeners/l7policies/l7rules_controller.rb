module Lbaas2
  module Loadbalancers
    module Listeners
      module L7policies
        class L7rulesController < ApplicationController

          def index
            per_page = (params[:per_page] || 9999).to_i
            pagination_options = { sort_key: 'type', sort_dir: 'asc', limit: per_page + 1 }
            pagination_options[:marker] = params[:marker] if params[:marker]

            l7rules = services.lbaas2.l7rules(params[:l7policy_id], pagination_options) 
            render json: {
              l7rules: l7rules,
              has_next: l7rules.length > per_page
            }
          rescue Elektron::Errors::ApiResponse => e
            render json: { errors: e.message }, status: e.code
          rescue Exception => e
            render json: { errors: e.message }, status: "500"
          end

          def create
            # add project id
            l7RuleParams = params[:l7rule].merge(project_id: @scoped_project_id, l7policy_id: params[:l7policy_id]) #listener_id: params[:listener_id],
            l7rule = services.lbaas2.new_l7rule(l7RuleParams)
            if l7rule.save
              audit_logger.info(current_user, 'has created', l7rule)
              render json: l7rule
            else
              render json: {errors: l7rule.errors}, status: 422
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
end
