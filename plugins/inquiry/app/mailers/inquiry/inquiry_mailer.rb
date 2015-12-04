module Inquiry
  class InquiryMailer < ApplicationMailer

    def notification_email_requester(user_email, user_full_name, inquiry_step)
      return unless user_email
      @user_email = user_email
      @user_full_name  = user_full_name
      @inquiry_step = inquiry_step
      mail(to: @user_email, subject: "Converged Cloud: Your inquiry was #{@inquiry_step.inquiry.aasm.human_state}")
    end

    def notification_email_processors(processor_emails, inquiry_step)
      return if processor_emails.blank?
      @inquiry_step = inquiry_step
      mail(to: processor_emails, subject: "Converged Cloud: Please process an SAP Converged Cloud inquiry")
    end

  end
end
