module Image
  class OsImages::PublicController < OsImagesController
    private

    def load_visibility
      @visibility = 'public'.freeze
    end
  end
end
