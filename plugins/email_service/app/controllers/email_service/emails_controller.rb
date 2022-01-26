module EmailService
  class EmailsController < ::EmailService::ApplicationController

    before_action :restrict_access

    authorization_context 'email_service'
    authorization_required

    def index
      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
      @verified_emails_collection = get_verified_identities_collection(@verified_emails, "EmailAddress")
      @all_domains = list_verified_identities("Domain")
      @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
      @verified_domains_collection = get_verified_identities_collection(@verified_domains, "Domain") unless @verified_domains.nil? || @verified_domains.empty?
      @send_data = get_send_data
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : ERR: #{e.message}"
    end

  end
end

