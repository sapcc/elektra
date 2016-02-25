module ObjectStorage
  class ApplicationController < DashboardController
    # This is the base class of all controllers in this plugin. Only put code in here that is shared across controllers.
    authorization_context 'object_storage'

    protected

    def metadata_params
      metadata_keys   = params.require(:metadata).require(:keys)
      metadata_values = params.require(:metadata).require(:values)
      metadata = {}
      metadata_keys.each_with_index do |key, index|
        next if key.blank? # skip empty rows
        metadata[key] = metadata_values[index]
      end
      return metadata
    end

  end
end
