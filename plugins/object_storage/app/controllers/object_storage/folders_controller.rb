module ObjectStorage
  class FoldersController < ApplicationController

    authorization_required
    before_filter :load_params

    def new_object
      @new_object = Core::ServiceLayer::Model.new(nil, file: '', filename: '')
    end

    def create_object
      # because we use a Core::ServiceLayer::Model object as a shim for the
      # simple_form, the params are named accordingly
      upload_params = params.require(:core_service_layer_model)
      file          = upload_params.require(:file)
      filename      = upload_params[:filename] || file.original_filename
      services.object_storage.create_object(@container_name, @object.path + filename, file)

      respond_to do |format|
        format.js
        format.html { redirect_to plugin('object_storage').list_objects_path(@container_name, @object.path) }
      end
    rescue ActionController::ParameterMissing
      @new_object = Core::ServiceLayer::Model.new(nil, file: '', filename: filename || '')
      @missing_file = true
      render action: 'new_object'
    end

    private

    def load_params
      # do not load the whole container object as it is not needed usually
      @container_name = params[:container]

      # params[:path] is optional to account for the "/" path (which Rails
      # routing recognizes as empty), but then it is given as nil
      params[:path] ||= ''

      # we want to use the helper methods on ObjectStorage::Object, but the
      # folder identified by params[:path] need not necessarily exist as an
      # object (i.e. find_object() might fail with 404)
      params[:path] += '/' unless params[:path].end_with?('/')
      @object = ObjectStorage::Object.new(nil, id: params[:path])
    end

  end
end
