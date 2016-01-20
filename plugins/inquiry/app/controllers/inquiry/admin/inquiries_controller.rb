module Inquiry
  module Admin
    class InquiriesController < ::Inquiry::InquiriesController
      authorization_actions_for :Inquiry, all_actions: :update
    end
  end
end
