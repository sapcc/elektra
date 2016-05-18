module Image
  class OsImages::PublicController < OsImagesController
    def visibility
      @visibility = 'public'.freeze
    end
  end
end
