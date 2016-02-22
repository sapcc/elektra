module ObjectStorage
  class ContainersController < ApplicationController

    authorization_required
    before_filter :load_container, except: [ :index, :new, :create ]

    def index
      @containers = services.object_storage.containers
    end

    def show
    end

    def new
      @container = services.object_storage.new_container(id: "")
    end

    def create

      name = params[:container][:name]
      @container = services.object_storage.new_container(name: name)
      unless @container.save
        render action: 'new'
        return
      end
      @containers = services.object_storage.containers

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
      @container = services.object_storage.find_container(params[:container])
      raise ActiveRecord::RecordNotFound, "container #{params[:container]} not found" unless @container
    end

  end
end
