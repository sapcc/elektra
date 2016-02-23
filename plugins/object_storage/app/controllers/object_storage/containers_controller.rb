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
      @container = services.object_storage.new_container(name: "")
    end

    def create
      @container = services.object_storage.new_container(params.require(:container))
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
      @form = ObjectStorage::Forms::ConfirmContainer.new(params.require(:forms_confirm_container))
      unless @form.validate
        render action: 'confirm_deletion'
        return
      end
      @container.destroy
      @containers = services.object_storage.containers
    end

    private

    def load_container
      @container = services.object_storage.find_container(params[:container])
      raise ActiveRecord::RecordNotFound, "container #{params[:container]} not found" unless @container
    end

  end
end
