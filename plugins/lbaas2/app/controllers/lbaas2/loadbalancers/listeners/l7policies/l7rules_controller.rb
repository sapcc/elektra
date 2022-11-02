module Lbaas2
  module Loadbalancers
    module Listeners
      module L7policies
        class L7rulesController < ::AjaxController
          authorization_context 'lbaas2'
          authorization_required

          def index
            limit = (params[:limit] || 9999).to_i
            sort_key = (params[:sort_key] || 'type')
            sort_dir = (params[:sort_dir] || 'asc')
            pagination_options = { sort_key: sort_key, sort_dir: sort_dir, limit: limit + 1 }
            pagination_options[:marker] = params[:marker] if params[:marker]

            l7rules = services.lbaas2.l7rules(params[:l7policy_id], pagination_options) 
            render json: {
              l7rules: l7rules,
              has_next: l7rules.length > limit,
              limit: limit, sort_key: sort_key, sort_dir: sort_dir
            }
          rescue Elektron::Errors::ApiResponse => e
            render json: { errors: e.message }, status: e.code
          rescue Exception => e
            render json: { errors: e.message }, status: "500"
          end

          def show
            l7rule = services.lbaas2.find_l7rule(params[:l7policy_id], params[:id])
            render json: {
              l7rule: l7rule
            }
          rescue Elektron::Errors::ApiResponse => e
            render json: { errors: e.message }, status: e.code
          rescue Exception => e
            render json: { errors: e.message }, status: "500"
          end  
          
          def create
            # add project id
            l7ruleParams = params[:l7rule].merge(project_id: @scoped_project_id, l7policy_id: params[:l7policy_id]) #listener_id: params[:listener_id],
            l7rule = services.lbaas2.new_l7rule(l7ruleParams)
            if l7rule.save
              audit_logger.info(current_user, 'has created', l7rule)
              render json: {
                l7rule: l7rule
              }
            else
              render json: {errors: l7rule.errors}, status: 422
            end
          rescue Elektron::Errors::ApiResponse => e
            render json: { errors: e.message }, status: e.code
          rescue Exception => e
            render json: { errors: e.message }, status: "500"
          end

          def update
            newParams = params[:l7rule].merge(l7policy_id: params[:l7policy_id])
            l7rule = services.lbaas2.new_l7rule(newParams)
            if l7rule.update
              audit_logger.info(current_user, 'has updated', l7rule)
              render json: {
                l7rule: l7rule
              }   
            else
              render json: {errors: l7rule.errors}, status: 422
            end
          rescue Elektron::Errors::ApiResponse => e
            render json: { errors: e.message }, status: e.code
          rescue Exception => e
            render json: { errors: e.message }, status: "500"
          end

          def destroy
            l7rule = services.lbaas2.new_l7rule
            l7rule.l7policy_id = params[:l7policy_id]
            l7rule.id = params[:id]
            
            if l7rule.destroy
              audit_logger.info(current_user, 'has deleted', l7rule)
              head 202
            else  
              render json: { errors: l7rule.errors }, status: 422
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
