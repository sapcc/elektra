module ObjectStorage
  class ContainersController < ApplicationController

    authorization_required
    before_filter :load_container, except: [ :index, :new, :create ]

    def index
      @containers = services.object_storage.containers
    end

    def confirm_deletion
      @form = ObjectStorage::Forms::ConfirmContainerAction.new()
      @empty = @container.empty?
    end

    def confirm_emptying
      @form = ObjectStorage::Forms::ConfirmContainerAction.new()
      @empty = @container.empty?
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
      @container.empty!
      if @form.reload_list == "true"
        @containers = services.object_storage.containers
        back_to_container_list
      else
       redirect_to plugin('object_storage').list_objects_path(@form.name, "")
      end
    end

    def create
      @container = services.object_storage.new_container(params.require(:container))
      unless @container.save
        render action: 'new'
        return
      end

      back_to_container_list
    end

    def update
      # TODO: conflict: params[:container] comes from the route, but may in the
      # future also come from SimpleForm input elements

      @container.metadata = self.metadata_params
      unless @container.save
        render action: 'show' # "edit" view is covered by "show"
        return
      end

      back_to_container_list
    end

    def destroy
      @form = ObjectStorage::Forms::ConfirmContainerAction.new(params.require(:forms_confirm_container_action))
      unless @form.validate
        render action: 'confirm_deletion'
        return
      end
      
      @container.destroy
      if @form.reload_list == "true"
        @containers = services.object_storage.containers
        back_to_container_list
      else
        redirect_to plugin('object_storage').containers_path()
      end
    end

    private

    def load_container
      @container = services.object_storage.find_container(params[:container])
      raise ActiveRecord::RecordNotFound, "container #{params[:container]} not found" unless @container
    end

    def back_to_container_list
      respond_to do |format|
        format.js do
          @containers = services.object_storage.containers
          render action: 'reload_container_list'
        end
        format.html { redirect_to plugin('object_storage').containers_path }
      end
    end

  end
end
