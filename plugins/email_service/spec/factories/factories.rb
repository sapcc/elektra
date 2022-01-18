module EmailService

  class FakeFactory

    def plain_email
      EmailService::PlainEmailHelper::PlainEmail.new(plain_email_opts)
    end

    def templated_email
      EmailService::TemplatedEmailHelper::TemplatedEmail.new(templated_email_opts)
    end

    def configset 
      EmailService::ConfigsetHelper::Configset.new(configset_opts)
    end

    def plain_email_opts
      plain_email_opts = {
        source: "abc@def.com",
        to_addr: "abc@def.com, ghi@rbss.de",
        cc_addr: "klm@yur.kr, rjuhu@hyrtyd.co.uk", 
        bcc_addr: "abc@xyz.mn.rb, kd@mr.jq.lk", 
        subject: "Sample Subject", 
        htmlbody: "<html><head><title>TEST</title><body><h1>Body of the HTML email<h1></body></html>", 
        textbody: "Body of the PLAIN email"
      }
    end

    def templated_email_opts
      templated_email_opts = {
        source: "abc@def.com",
        to_addr: "abc@def.com, ghi@rbss.de",
        cc_addr: "klm@yur.kr, rjuhu@hyrtyd.co.uk", 
        bcc_addr: "abc@xyz.mn.rb, kd@mr.jq.lk", 
        template: "MyTemplate", 
        configset: "MyConfigSet"
      }
    end

    def configset_opts
      configset_opts = {
        id: 0, 
        name: "New ConfigSet"
      }
    end

  end

end
