module EmailService

  class FakeFactory

    def plain_email
      EmailService::Forms::PlainEmail.new(plain_email_opts)
    end

    def templated_email
      EmailService::Forms::TemplatedEmail.new(templated_email_opts)
    end

    def configset 
      EmailService::Configset.new(configset_opts)
    end

    def template
      EmailService::Template.new(template_opts)
    end

    def aws_creds_error
      ServiceLayer::IdentityServices::Credential::AWSCreds.new("", "", "Error occured")
    end

    def aws_creds_array
      creds_array = []
      2.times do
        creds_array << ServiceLayer::IdentityServices::Credential::AWSCreds.new("abcdefghijk", "abcdefghijk", "")
      end
      creds_array
    end

    def plain_email_opts
      {
        source: "abc@def.com",
        to_addr: "abc@def.com, ghi@rbss.de",
        cc_addr: "klm@yur.kr, rjuhu@hyrtyd.co.uk", 
        bcc_addr: "abc@xyz.mn.rb, kd@mr.jq.lk", 
        subject: "Sample Subject", 
        htmlbody: "<html><head><title>TEST</title><body><h1>Body of the HTML email<h1></body></html>", 
        textbody: "Body of the PLAIN email"
      }
    end

    def template_opts
      {
        id: 0,
        name: "new template",
        subject: "Subject of the new template",
        html_part: "<h1>HTML Content of the eMail </h1>",
        text_part: "Content of the eMail"
      }
    end

    def templated_email_opts
      {
        source: "abc@def.com",
        to_addr: "abc@def.com, ghi@rbss.de",
        cc_addr: "klm@yur.kr, rjuhu@hyrtyd.co.uk", 
        bcc_addr: "abc@xyz.mn.rb, kd@mr.jq.lk", 
        template_name: "MyTemplate", 
        template_data: '{ "abc": { "def": "klm"}}', 
        configset: "MyConfigSet"
      }
    end

    def configset_opts 
      {
        id: 0, 
        name: "NewConfigSet"
      }
    end

    def verfied_email_opts
      { id: 0, identity: "abc@ghi.com" }
    end

    def verfied_domain_opts
      { id: 0, identity: "test.ghi.com", dkim_enabled: true }
    end

  end

end
