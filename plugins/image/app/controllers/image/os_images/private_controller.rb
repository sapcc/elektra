module Image
  class OsImages::PrivateController < OsImagesController
    def visibility
      @visibility = 'private'.freeze
    end
  end
end
