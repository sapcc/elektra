# frozen_string_literal: true

module EmailService
  # StatisticsController
  class StatisticsController < ::EmailService::ApplicationController
    before_action :check_pre_conditions_for_cronus

    authorization_context 'email_service'
    authorization_required

    def index
      domain = domains_collection&.first
      Rails.logger.debug "\n controller : #{domain}"
      seconds_per_day = 24*60*60
      total_days = 29
      report_start_date = Time.now - ( seconds_per_day * total_days )
      report_end_date = Time.now
      Rails.logger.debug "\n report_start_date : #{report_start_date}"
      Rails.logger.debug "\n report_end_date : #{report_end_date}"
      Rails.logger.debug "\n identity : #{domain}"
      @domain_statistics_report = domain_statistics_report(domain, report_start_date, report_end_date)
    end
  end
end
