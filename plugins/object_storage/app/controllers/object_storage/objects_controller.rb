module ObjectStorage
  class ObjectsController < ApplicationController

    authorization_required
    before_filter :load_params
    before_filter :load_object, except: [ :index ]

    def index
      @objects = services.object_storage.list_objects_at_path(@container_name, params[:path])
    end

    def show
    end

    def download
      headers['Content-Type'] = @object.content_type
      disposition = params[:inline] == '1' ? 'inline' : 'attachment'
      headers['Content-Disposition'] = "#{disposition}; filename=\"#{@object.basename}\""
      render body: @object.file_contents
    end

    def update
      @object.metadata = self.metadata_params
      unless @object.save
        render action: 'show' # "edit" view is covered by "show"
        return
      end

      back_to_object_list
    end

    def new_copy
      @form = ObjectStorage::Forms::CreateCopy.new(
        container_name: @container_name,
        path:           @object.path,
        with_metadata:  true,
      )
      @all_container_names = services.object_storage.containers.map(&:name).sort
    end

    def create_copy
      @form = ObjectStorage::Forms::CreateCopy.new(params.require(:forms_create_copy).merge(
        source_container_name: @container_name,
        source_path:           @object.path,
      ))

      unless @form.validate
        @all_container_names = services.object_storage.containers.map(&:name).sort
        puts "ATTRIBUTES: #{@form.attributes.inspect}"
        render action: 'new_copy'
        return
      end

      @object.copy_to(@form.container_name, @form.path, with_metadata: @form.with_metadata == "1")
      back_to_object_list
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
      @object = services.object_storage.find_object(@container_name, params[:path])
      if (not @object) or @object.is_directory?
        raise ActiveRecord::RecordNotFound, "object #{params[:path]} not found in container #{@container_name}"
      end
    end

    def back_to_object_list
      respond_to do |format|
        format.js do
          @objects = services.object_storage.list_objects_at_path(@container_name, @object.dirname)
          render template: '/object_storage/objects/reload_index'
        end
        format.html { redirect_to plugin('object_storage').list_objects_path(@container_name, @object.dirname) }
      end
    end

  end
end
