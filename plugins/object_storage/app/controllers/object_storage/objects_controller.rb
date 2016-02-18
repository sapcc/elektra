module ObjectStorage
  class ObjectsController < ApplicationController

    authorization_required
    before_filter :load_params
    before_filter :load_object, except: [ :index, :upload, :upload_form ]
    before_filter :load_dummy_directory_object, only: [ :upload, :upload_form ]

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

    def upload_form
      @new_object = Core::ServiceLayer::Model.new(nil, file: '', filename: '')
    end

    def upload
      # because we use a Core::ServiceLayer::Model object as a shim for the
      # simple_form, the params are named accordingly
      upload_params = params.require(:core_service_layer_model)
      file          = upload_params.require(:file)
      filename      = upload_params[:filename] || file.original_filename
      services.object_storage.create_object(@container_name, @object.path + filename, file)
    rescue ActionController::ParameterMissing
      @new_object = Core::ServiceLayer::Model.new(nil, file: '', filename: filename || '')
      @missing_file = true
      render action: 'upload_form'
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

    def load_dummy_directory_object
      # used by methods where params[:path] is given and we want to use the
      # various helper methods on ObjectStorage::Object, but the object
      # identified by params[:path] is a directory or pseudo-directory that
      # need not necessarily exist in Swift (e.g. find_object() on a
      # pseudo-directory will fail)
      params[:path] += '/' unless params[:path].end_with?('/')
      @object = ObjectStorage::Object.new(nil, id: params[:path])
    end

  end
end
