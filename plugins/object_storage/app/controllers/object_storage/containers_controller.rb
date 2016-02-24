module ObjectStorage
  class ContainersController < ApplicationController

    authorization_required
    before_filter :load_container, except: [ :index, :new, :create ]

    def index
      @containers = services.object_storage.containers
    end

    def confirm_deletion
      @form = ObjectStorage::Forms::ConfirmContainerAction.new()
    end

    def confirm_emptying
      @form = ObjectStorage::Forms::ConfirmContainerAction.new()
    end

    def show
    end

    def new
      @container = services.object_storage.new_container(name: "")
    end

    def empty
      @form = ObjectStorage::Forms::ConfirmContainerAction.new(params.require(:forms_confirm_container_action))
      unless @form.validate
        render action: 'confirm_emptying'
        return
      end
      services.object_storage.empty_container(params.require(:forms_confirm_container_action).require(:name))

      @containers = services.object_storage.containers
      respond_to do |format|
        format.js { render action: 'reload_container_list' }
      end
    end

    def create
      @container = services.object_storage.new_container(params.require(:container))
      unless @container.save
        render action: 'new'
        return
      end
      @containers = services.object_storage.containers
      respond_to do |format|
        format.js { render action: 'reload_container_list' }
      end
    end

    def edit
      # TODO
    end

    def update
      # TODO
    end

    def destroy
      @form = ObjectStorage::Forms::ConfirmContainerAction.new(params.require(:forms_confirm_container_action))
      unless @form.validate
        render action: 'confirm_deletion'
        return
      end
      @container.destroy
      @containers = services.object_storage.containers

      respond_to do |format|
        format.js { render action: 'reload_container_list' }
      end
    end

    private

    def load_container
      @container = services.object_storage.find_container(params[:container])
      raise ActiveRecord::RecordNotFound, "container #{params[:container]} not found" unless @container
    end

  end
end
