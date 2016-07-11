module Image
  class OsImages::SharedController < OsImagesController
    private

    def load_visibility
      @visibility = 'shared'.freeze
    end
  end
end
