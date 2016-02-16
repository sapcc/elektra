module Swift
  class ObjectsController < ApplicationController

    authorization_required
    before_filter :load_params
    before_filter :load_object, except: [ :index ]

    def index
      @objects = services.swift.list_objects_at_path(@container_name, params[:path])
    end

    def download
      # TODO
    end

    private

    def load_params
      # do not load the whole container object as it is not needed usually
      @container_name = params[:container]
      # params[:path] is optional in some controllers to account for the "/"
      # path (which Rails routing recognizes as empty), but then it is given as nil
      params[:path] ||= ''
    end

    def load_object
      @object = services.swift.find_object(@container_name, params[:path])
      raise ActiveRecord::RecordNotFound, "object #{params[:object]} not found in container #{@container_name}" unless @object
    end

  end
end
