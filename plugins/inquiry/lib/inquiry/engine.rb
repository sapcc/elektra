require_relative "../../app/helpers/inquiry/inquiries_helper"
module Inquiry
  class Engine < ::Rails::Engine
    isolate_namespace Inquiry

    initializer "inquiry.action_controller" do |app|
      ActiveSupport.on_load :action_controller do
        helper Inquiry::InquiriesHelper
      end
    end
  end

  class InquiryError < StandardError
  end
end
