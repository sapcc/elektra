# frozen_String_literal: true

module ServiceLayer
  module EmailServiceServices
    # cronus account api implementation
    module CronusAccount

      # # cronus account api implementation
      # result = {"DedicatedIpAutoWarmupEnabled":true,"Details":{"AdditionalContactEmailAddresses":["anton.khramov@sap.com","d.halimi@sap.com","ran.cliff@sap.com"],"ContactLanguage":"EN","MailType":"TRANSACTIONAL","ReviewDetails":{"CaseId":"8980649361","Status":"GRANTED"},"UseCaseDescription":"Confirmation of AWS Acceptable Use Policy [1] and AWS Service Terms [2].\nHow do you plan to build or acquire your mailing list (if applicable)? SAP Available mailing list\nHow do you plan to handle bounces and complaints [3]? SAP Monitoring Tools\nHow can recipients opt out of receiving email from you (if applicable)? SAP Application UI\nHow did you choose the sending rate or sending quota that you specified in this request? Out of Sandbox\nAre you solely sending information only to recipients who have specifically requested your mail? Yes\n","WebsiteURL":"https://www.sap.com"},"EnforcementStatus":"HEALTHY","ProductionAccessEnabled":true,"SendQuota":{"Max24HourSend":1000000.0,"MaxSendRate":500.0,"SentLast24Hours":0.0},"SendingEnabled":true,"SuppressionAttributes":{"SuppressedReasons":["BOUNCE","COMPLAINT"]},"VdmAttributes":null}
      # endpoint = https://{cronus_endpoint}}/v2/email/account/

      def cronus_account_map
        @cronus_account_map ||= class_map_proc(::EmailService::CronusAccount)
      end

      def cronus_account(options = {})
        return nil if options == {}
        #TODO:
        # Implement Amazon options, if it has to be called from elektron
        elektron_cronus.get("email/account", options).map_to("body", &cronus_account_map)
      end
    end
  end
end
