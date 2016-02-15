module Swift
  class ContainersController < ApplicationController

    authorization_required
    before_filter :load_container, except: [ :index, :new, :create ]

    def index
      @containers = services.swift.containers
    end

    def show
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
      @container = services.swift.find_container(params[:id])
      raise ActiveRecord::RecordNotFound, "container #{params[:id]} not found" unless @container
    end

  end
end
