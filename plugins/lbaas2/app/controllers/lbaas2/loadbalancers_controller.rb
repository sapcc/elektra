# frozen_string_literal: true

module Lbaas2
  class LoadbalancersController < DashboardController
    def index
      if request.format.json?
        # get paginated loadbalancers
        per_page = params[:per_page] || 20
        per_page = per_page.to_i
        loadbalancers = paginatable(per_page: per_page) do |pagination_options|
          services.lbaas.loadbalancers({ project_id: @scoped_project_id, sort_key: 'id' }.merge(pagination_options))
        end
      end

      respond_to do |format|
        format.html
        format.json { render json: loadbalancers }
      end
    end
  end
end
