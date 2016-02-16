module Swift
  class ContainersController < ApplicationController

    authorization_required
    before_filter :load_container, except: [ :index, :new, :create ]

    def index
      @containers = services.swift.containers
    end

    def show
      redirect_to plugin('swift').list_objects_path(@container.name, path: '')
    end

    def new
      # TODO
    end

    def create
      # TODO
    end

    def edit
      # TODO
    end

    def update
      # TODO
    end

    def destroy
      # TODO
    end

    private

    def load_container
      @container = services.swift.find_container(params[:container])
      raise ActiveRecord::RecordNotFound, "container #{params[:container]} not found" unless @container
    end

  end
end
