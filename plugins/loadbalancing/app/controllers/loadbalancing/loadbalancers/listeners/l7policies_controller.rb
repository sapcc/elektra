module Loadbalancing
  module Loadbalancers
    module Listeners
      class L7policiesController < ApplicationController

        before_filter :load_objects

        # set policy context
        authorization_context 'loadbalancing'
        # enforce permission checks. This will automatically investigate the rule name.
        authorization_required except: [:update_item]

        def index
          @l7policies = paginatable(per_page: 20) do |pagination_options|
            services.loadbalancing.l7policies({loadbalancer_id: params[:loadbalancer_id], listener_id: params[:listener_id],
                                               sort_key: 'position', sort_dir: 'asc'}.merge(pagination_options))
          end
        end


        def new
          @pools = services.loadbalancing.pools({loadbalancer_id: params[:loadbalancer_id]})
          @l7policy = services.loadbalancing.new_l7policy
        end

        def create
          @l7policy = services.loadbalancing.new_l7policy
          @l7policy.attributes = l7policy_params.merge(listener_id: @listener.id)
          if @l7policy.save
            audit_logger.info(current_user, "has created", @l7policy)
            redirect_to loadbalancer_listener_l7policies_path(loadbalancer_id: params[:loadbalancer_id], listener_id: params[:listener_id]), notice: 'L7 Policy created.'
          else
            @pools = services.loadbalancing.pools({loadbalancer_id: params[:loadbalancer_id]})
            render :new
          end
        end


        def show
          @l7policy = services.loadbalancing.find_l7policy(params[:id])
        end


        def edit
          @pools = services.loadbalancing.pools({loadbalancer_id: params[:loadbalancer_id]})
          @l7policy = services.loadbalancing.find_l7policy(params[:id])
        end


        def update
          @l7policy = services.loadbalancing.find_l7policy(params[:id])
          if @l7policy.update(l7policy_params)
            audit_logger.info(current_user, "has updated", @l7policy)
            redirect_to loadbalancer_listener_l7policies_path(loadbalancer_id: params[:loadbalancer_id], listener_id: params[:listener_id]), notice: 'L7 Policy was successfully updated.'
          else
            @pools = services.loadbalancing.pools({loadbalancer_id: params[:loadbalancer_id]})
            render :edit
          end
        end

        def destroy
          @l7policy = services.loadbalancing.find_l7policy(params[:id])
          @l7policy.destroy
          audit_logger.info(current_user, "has deleted", @l7policy)
          render template: 'loadbalancing/loadbalancers/listeners/l7policies/destroy_item.js'
        end

        # update instance table row (ajax call)
        def update_item
          begin
            @l7policy = services.loadbalancing.find_l7policy(params[:id])
            respond_to do |format|
              format.js do
                @l7policy if @l7policy
              end
            end
          rescue => e
            return nil
          end
        end

        private

        def l7policy_params
          p = params[:l7policy]
          p['redirect_url'] = nil unless p['action'] == 'REDIRECT_TO_URL'
          p['redirect_pool_id'] = nil unless p['action'] == 'REDIRECT_TO_POOL'
          return p
        end

        def load_objects
          @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
          @listener = services.loadbalancing.find_listener(params[:listener_id])
        end

      end
    end
  end
end
