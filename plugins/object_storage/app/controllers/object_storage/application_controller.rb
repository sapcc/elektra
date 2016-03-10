module ObjectStorage
  class ApplicationController < ::DashboardController
    # This is the base class of all controllers in this plugin. Only put code in here that is shared across controllers.
    authorization_context 'object_storage'

    rescue_from Excon::Errors::Error do |exception|
      # get exception message
      @exception_msg = exception.to_s

      # serialize request if it is avilable
      if req = exception.request
        str = "#{req[:method].to_s.upcase} #{req[:path]}\n"
        hdr = req[:headers] || {}
        hdr.keys.sort.each do |key|
          value = key.end_with?('-Token') ? '*****' : hdr[key]
          str += "#{key}: #{value}\n"
        end
        @request_dump = str
      end

      render template: '/object_storage/application/backend_error'
    end

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
