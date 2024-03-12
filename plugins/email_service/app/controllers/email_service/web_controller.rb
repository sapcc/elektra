# frozen_string_literal: true

module EmailService
  # WebController
  class WebController < ::EmailService::ApplicationController
    # before_action :ui_switcher

    # before_action :check_pre_conditions_for_cronus

    authorization_context 'email_service'
    authorization_required

    def index
    end

    def test
      @nebula_details = nebula_details
      @nebula_status = nebula_status
      @nebula_endpoint = nebula_endpoint_url
      @templates = get_all_email_templates
      @email_service_url = email_service_url
      @aws_account_details = aws_account_details
      @templates = templates
      @cloud_watch_put_dashboard = cloud_watch_put_dashboard
      @cloud_watch_client = cloud_watch_client
    end

    def send_plain_email_with_domain_source
      attributes = {
        source: ENV['SOURCE_DOMAIN_EMAIL'],
        source_domain: ENV['VERIFIED_EMAIL_DOAMIN'],
        source_domain_name_part: 'test',
        source_email: ENV['SOURCE_DOMAIN_EMAIL'],
        source_type: 'DOMAIN',
        to_addr: [ENV['TO_EMAIL']],
        cc_addr: [ENV['CC_EMAIL']],
        bcc_addr: [ENV['BCC_EMAIL']],
        reply_to_addr: [ENV['DOMAIN_REPLY_TO_ADDR']],
        return_path: ENV['DOMAIN_RETURN_PATH'],
        subject: "#{ENV['SUBJECT']} : #{Time.now}",
        html_body: "<h1>#{ ENV['HTML_BODY'] } : #{Time.now}</h1>",
        text_body: "#{ENV['TEXT_BODY']} : #{Time.now}",
        configuration_set_name: ENV['CONFIGURATION_SET_NAME'],
      }
      plain_email = EmailService::Forms::PlainEmail.new(attributes)
      resp = send_plain_email(plain_email)
    end

    def send_plain_email_with_email_source
      attributes = {
        source: ENV['VERIFIED_EMAIL_ADDRESS'],
        source_email: ENV['VERIFIED_EMAIL_ADDRESS'],
        source_type: 'EMAIL',
        to_addr: [ENV['TO_EMAIL']],
        cc_addr: [ENV['CC_EMAIL']],
        bcc_addr: [ENV['BCC_EMAIL']],
        reply_to_addr: [ENV['REPLY_TO_ADDR']],
        return_path: ENV['RETURN_PATH'],
        subject: "#{ENV['SUBJECT']} : #{Time.now}",
        html_body: "<h1>#{ENV['HTML_BODY']} : #{Time.now}</h1>",
        text_body: "#{ENV['TEXT_BODY']} : #{Time.now}",
        configuration_set_name: ENV['CONFIGURATION_SET_NAME'],
      }
      plain_email = EmailService::Forms::PlainEmail.new(attributes)
      resp = send_plain_email(plain_email)
    end

  end
end
