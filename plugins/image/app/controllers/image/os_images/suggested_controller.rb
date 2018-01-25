module Image
  class OsImages::SuggestedController < OsImagesController
    before_action :find_member, only: [:accept, :reject]

    def accept
      @success = services.image.accept_member(@member)
      render action: :accept, format: :js
    end

    def reject
      @success = services.image.reject_member(@member)
      render action: :reject, format: :js
    end

    protected
    def filter_params
      { sort_key: 'name', visibility: 'shared', member_status: 'pending' }
    end

    def find_member
      members = services.image.members(params[:suggested_id])
      @member = catch :found do
        members.each do |m|
          throw :found, m if m.member_id == @scoped_project_id && m.status == 'pending'
        end
        nil
      end
    end
  end
end
