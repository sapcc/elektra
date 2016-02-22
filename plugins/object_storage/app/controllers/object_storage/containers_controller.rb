module ObjectStorage
  class ContainersController < ApplicationController

    authorization_required
    before_filter :load_container, except: [ :index, :new, :create ]

    def index
      @containers = services.object_storage.containers
    end

    def confirm_deletion
      @form = ObjectStorage::Forms::ConfirmContainer.new()
    end

    def show
    end

    def new
      @container = services.object_storage.new_container(name: '')
    end

    def create
      # TODO: How to do error handling?
      #  * check existing container
      #  * not allowed characters?
      #  * empty name

      name = params.require(:container).require(:name)
      new_container = services.object_storage.new_container(name: name)
      new_container.save
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
