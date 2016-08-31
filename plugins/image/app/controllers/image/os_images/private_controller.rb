module Image
  class OsImages::PrivateController < OsImagesController
    
    protected
    def filter_params
      {sort_key: 'name', visibility: 'private'}
    end
  end
end
