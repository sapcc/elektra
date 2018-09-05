module ObjectStorage
  class FoldersController < ObjectStorage::ApplicationController

    authorization_required
    before_action :load_params
    before_action :load_quota_data, only: [ :index, :show ]

    def new_object
      @form = ObjectStorage::Forms::CreateObject.new(file: nil, name: '')
    end

    def create_object
      @form = ObjectStorage::Forms::CreateObject.new(params.require(:forms_create_object))
      @form.name = @form.file.original_filename if @form.file and not @form.name
      unless @form.validate
        render action: 'new_object'
        return
      end

      services.object_storage.create_object(@container_name, @object.path + @form.name, @form.file)
      # to prevent problems with weird container names like "echo 1; rm -rf *)"
      # the name must be form encoded to load it properly
      back_to_object_list(URI.encode_www_form_component(@container_name), URI.encode_www_form_component(@object.path))
    end

    def new_folder
      @form = ObjectStorage::Forms::CreateFolder.new(name: '')
    end

    def create_folder
      @form = ObjectStorage::Forms::CreateFolder.new(params.require(:forms_create_folder))
      unless @form.validate
        render action: 'new_folder'
        return
      end

      services.object_storage.create_folder(@container_name, @object.path + @form.name)
      back_to_object_list(@container_name, @object.path)
    end

    def destroy
      services.object_storage.delete_folder(@container_name, @object.path)
      back_to_object_list(@container_name, @object.dirname)
    end

    private

    def load_params

      # to prevent problems with weird container names like "echo 1; rm -rf *)"
      # the name is form encoded and must be decoded here
      @container_name = URI.decode_www_form_component(params[:container])
      # do not load the whole container object as it is not needed usually

      # params[:path] is optional to account for the "/" path (which Rails
      # routing recognizes as empty), but then it is given as nil
      params[:path] ||= ''
      params[:path] = URI.decode_www_form_component(params[:path])

      # we want to use the helper methods on ObjectStorage::Object, but the
      # folder identified by params[:path] need not necessarily exist as an
      # object (i.e. find_object() might fail with 404)
      params[:path] += '/' unless params[:path].end_with?('/')
      @object = ObjectStorage::Object.new(nil, path: params[:path])
    end

    def back_to_object_list(container_name, path)
      respond_to do |format|
        format.js do
          @objects = services.object_storage.list_objects_at_path(container_name, path)
          render template: '/object_storage/objects/reload_index'
        end
        format.html { redirect_to plugin('object_storage').list_objects_path(container_name, path) }
      end
    end

  end
end
