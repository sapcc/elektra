# frozen_string_literal: true

module Cloudops
  class ObjectsController < DashboardController
    layout "cloudops"
    
    def index
      page = (params[:page] || 1).to_i
      per_page = 30

      scope = ::ObjectCache.all

      unless params[:type].blank?
        scope = scope.where(cached_object_type: params[:type])
      end

      unless params[:term].blank?
        scope = scope.search(params[:term])
      end

      objects = scope.limit(per_page + 1).offset(page-1)
      total = objects.except(:offset, :limit, :order).count
      has_next = objects.length > per_page
      objects = objects.to_a
      objects.pop if has_next

      render json: {items: objects, hasNext: has_next, total: total}
    end

    def types
      render json: ::ObjectCache.distinct
                                .pluck(:cached_object_type)
                                .delete_if(&:blank?)
    end

    def show
      render json: ::ObjectCache.where(id: params[:id]).first
    end
  end
end
