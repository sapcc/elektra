# frozen_string_literal: true

module EmailService
    # Nebula Account
    class CronusAccount < ::Core::ServiceLayer::Model
    

      def info
      {
        "DedicatedIpAutoWarmupEnabled":true,
        "Details":{
          "AdditionalContactEmailAddresses":
          [
            "anton.khramov@sap.com",
            "d.halimi@sap.com",
            "ran.cliff@sap.com"
          ],
            "ContactLanguage":"EN",
            "MailType":"TRANSACTIONAL",
            "ReviewDetails":{ 
              "CaseId":"123456890",
              "Status":"GRANTED"
            },
            "UseCaseDescription":
            "Confirmation of AWS Acceptable Use Policy [1] and AWS Service Terms [2].\nHow do you plan to build or acquire your mailing list (if applicable)? SAP Available mailing list\nHow do you plan to handle bounces and complaints [3]? SAP Monitoring Tools\nHow can recipients opt out of receiving email from you (if applicable)? SAP Application UI\nHow did you choose the sending rate or sending quota that you specified in this request? Out of Sandbox\nAre you solely sending information only to recipients who have specifically requested your mail? Yes\n",
            "WebsiteURL":"https://www.sap.com"
        },
        "EnforcementStatus":"HEALTHY",
        "ProductionAccessEnabled":true,
        "SendQuota":{
            "Max24HourSend":1000000.0,
            "MaxSendRate":500.0,
            "SentLast24Hours":0.0
          },
        "SendingEnabled":true,
        "SuppressionAttributes":{
          "SuppressedReasons":[ "BOUNCE","COMPLAINT" ]
        },
        "VdmAttributes":null
      }
      end

      strip_attributes
      # validation
      validates_presence_of :dedicated_ip_auto_warmup_enabled, message: "DedicatedIpAutoWarmupEnabled can't be empty"
      validates_presence_of :additional_contact_email_addresses, message: "AdditionalContactEmailAddresses can't be empty"
      validates_presence_of :contact_language, message: "ContactLanguage can't be empty (aws)"
      validates_presence_of :mail_type, message: "It should be either TRANSACTIONAL or MARKETING, choose one"
      # review details
      validates_presence_of :case_id, message:'CaseId can\'t be empty (aws)'
      validates_presence_of :status, message:'status can\'t be empty (aws)'

      validates_presence_of :usecase_description, message:'UseCaseDescription can\'t be empty (aws)'
      validates_presence_of :website_url, message:'WebsiteUrl can\'t be empty (aws)'
      
      validates_presence_of :enforcement_status, message:'EnforcementStatus can\'t be empty (aws)'
      validates_presence_of :production_access_enabled, message:'ProductionAccessEnabled can\'t be empty (aws)'
      # send_quota
      validates_presence_of :max_24_hour_send, message:'Max24HourSend can\'t be empty (aws)'
      validates_presence_of :max_send_rate, message:'MaxSendRate can\'t be empty (aws)'
      validates_presence_of :sent_last_24_hours, message:'SentLast24Hours can\'t be empty (aws)'
      
      validates_presence_of :sending_enabled, message:'SendingEnabled can\'t be empty (aws)'
      validates_presence_of :suppressed_reasons, message:'SuppressedReasons can\'t be empty (aws)- Should be BOUNCE or COMPLAINT or both '
      validates_presence_of :vdm_attributes, message:'VdmAttributes can\'t be empty (aws)'
  
    end
  end
    