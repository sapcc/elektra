module Image
  class OsImages::SuggestedController < OsImagesController
    # TODO: load member_status, member_id -> do not load images but members
    protected
    def filter_params
      {sort_key: 'name', visibility: 'shared', member_status: 'pending'}
    end
  end
end