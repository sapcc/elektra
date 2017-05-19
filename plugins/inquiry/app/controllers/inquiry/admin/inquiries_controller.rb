module Inquiry
  module Admin
    class InquiriesController < ::Inquiry::InquiriesController
      authorization_actions_for :Inquiry, all_actions: :update

      def index
        # get all different types of inquiries from the database
        @kinds_of_inquiries = [["All",""]] + ::Inquiry::Inquiry.pluck(:kind).uniq.sort

        domain_id = current_user.is_allowed?("cloud_admin") ? nil : current_user.user_domain_id
        filter_state =  case params[:show_only]
                        when "pending"
                          ['open']
                        when "processed"
                          ['closed','approved','rejected']
                        else
                          ['open']
                        end

        filter = {approver_domain_id: domain_id, processor_id: current_user.id, state: filter_state}
        filter.merge!(params[:filter]) if params[:filter]
        @page = params[:page] || 1
        @inquiries = ::Inquiry::Inquiry.filter(filter).order(created_at: :desc).page(@page).per(params[:per_page])

      end
    end
  end
end
