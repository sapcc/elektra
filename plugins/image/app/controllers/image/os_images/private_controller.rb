module Image
  class OsImages::PrivateController < OsImagesController
    private

    def load_visibility
      @visibility = 'private'.freeze
    end
  end
end
