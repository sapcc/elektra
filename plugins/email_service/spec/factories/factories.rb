module EmailService

  class FakeFactory

    def plain_email(params = {})
      ::EmailService::PlainEmailHelper::PlainEmail.new( {source: "sirajudheenam@gmail.com", 
                                      to_addr: "sirajudheenam@gmail.com, 
                                      abc.qa, abc@xyz.ab.in", 
                                      cc_addr: "V4abc@xyz1.com,kab,abc@def.ghi,
                                      a@w,2k4@o,abc@kaq.bcs", 
                                      bcc_addr: "P1abc@xyz1.com, mn$, 
                                      klm@bch.jku.ing.klm", 
                                      subject: "Miracle Subject", 
                                      htmlbody: "<h1> HTML Body</h1>", 
                                      textbody: "Text Body"
                                      })
    end

  end

end
