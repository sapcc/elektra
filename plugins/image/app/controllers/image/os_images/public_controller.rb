module Image
  class OsImages::PublicController < OsImagesController
    
    protected
    def filter_params
      {sort_key: 'name', visibility: 'public'}
    end
  end
end
