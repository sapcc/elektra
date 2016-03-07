module ObjectStorage
  class ContainersController < ApplicationController

    authorization_required
    before_filter :load_container, except: [ :index, :new, :create ]

    def index
      @containers   = services.object_storage.containers
      @capabilities = services.object_storage.capabilities
    end

    def confirm_deletion
      @form = ObjectStorage::Forms::ConfirmContainerAction.new()
      @empty = @container.empty?
    end

    def confirm_emptying
      @form = ObjectStorage::Forms::ConfirmContainerAction.new()
      @empty = @container.empty?
    end

    def show_access_control
    end

    def update_access_control
      # TODO: use update_attributes
      @container.read_acl = params[:container][:read_acl]
      @container.write_acl = params[:container][:write_acl]
      unless @container.save
        render action: 'show_access_control'
        return
      end
      back_to_container_list
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
      back_to_container_list
    end

    def create
      @container = services.object_storage.new_container(params.require(:container))
      unless @container.save
        render action: 'new'
        return
      end

      back_to_container_list
    end

    def show
      @capabilities = services.object_storage.capabilities
    end

    def update
      # set extra container values like quotas
      params.require(:container).each do |key,value|
        # ensure that validations are executed
        @container.send("#{key}=", value)
      end
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
      back_to_container_list
    end

    private

    def load_container
      @container = services.object_storage.find_container(params[:id])
      raise ActiveRecord::RecordNotFound, "container #{params[:id]} not found" unless @container
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
