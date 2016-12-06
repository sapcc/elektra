module Inquiry
  class InquiryMailer < ApplicationMailer

    def notification_email_requester(user_email, user_full_name, inquiry_step)
      return if user_email.blank?
      @user_email = user_email
      @user_full_name = user_full_name
      @inquiry_step = inquiry_step
      mail(to: @user_email, subject: "Converged Cloud: Your resource request is in state: #{@inquiry_step.inquiry.aasm.human_state}", :content_type => 'text/html')
    end

    def notification_email_processors(processor_emails, inquiry_step, requester)
      processor_emails.reject!(&:blank?)
      return if processor_emails.blank?
      @inquiry_step = inquiry_step
      @requester_name = "#{requester.full_name} (#{requester.name})"
      subject =  "Converged Cloud: Please process a resource request "
      if @inquiry_step.inquiry.tags
        if @inquiry_step.inquiry.tags['region']
          subject += " for region #{@inquiry_step.inquiry.tags['region']}"
        end
        if @inquiry_step.inquiry.tags['domain_name']
          subject += "/#{@inquiry_step.inquiry.tags['domain_name']}"
        end
      end
      mail(to: processor_emails, subject: subject, :content_type => 'text/html')
    end

  end
end
