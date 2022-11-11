module EmailService

  class FakeFactory

    def plain_email
      EmailService::Forms::PlainEmail.new(plain_email_opts)
    end

    def templated_email
      EmailService::Forms::TemplatedEmail.new(templated_email_opts)
    end

    def custom_verification_email_template
      EmailService::Forms::CustomVerificationEmailTemplate.new(custom_verification_email_template_opts)
    end

    def configset
      EmailService::Configset.new(configset_opts)
    end

    def template
      EmailService::Template.new(template_opts)
    end

    def verified_domain
      EmailService::VerifiedDomain.new(verified_domain_opts)
    end

    def verified_email
      EmailService::VerifiedEmail.new(verified_email_opts)
    end

    def verified_domain_opts

      domain_signing_selector = "some_selector"
      domain_signing_private_key = "domain_signing_private_key"
      next_signing_key_length = "RSA_1024_BIT"
      {
        id: "000002",
        identity: "identity.domain",
        domain_name: "abc.def",
        dkim_enabled: true,
        dkim_signing_attributes: {
          "domain_signing_selector" => domain_signing_selector,
          "domain_signing_private_key" => domain_signing_private_key,
          "next_signing_key_length" => next_signing_key_length,
        },
        tags: [
          {
            "key1"=> "value1"
          },
          {
            "key2"=> "value2"
          }
        ],
        configset_name: "configset_domain_name"
      }
    end

    def verified_email_opts
      domain_signing_selector = "some_selector"
      domain_signing_private_key = "domain_signing_private_key"
      next_signing_key_length = "RSA_1024_BIT"
      {
        id: "000001",
        identity: "identity.email",
        domain_name: "abc.def",
        dkim_enabled: true,
        dkim_signing_attributes: {
          "domain_signing_selector" => domain_signing_selector,
          "domain_signing_private_key" => domain_signing_private_key,
          "next_signing_key_length" => next_signing_key_length,
        },
        tags: [
          {
            "key1"=> "value1"
          },
          {
            "key2"=> "value2"
          }
        ],
        configset_name: "configset_email_name"
      }
    end

    def rsa_key_length
      @rsa_key_length = "RSA_1024_BIT"
    end

    def configsets_collection
      @configsets_collection = ["configset1", "configset2"]
    end


    def ec2_creds
      {
        "user_id"=>"xxxxxx_user_id_xxxxxx",
        "tenant_id"=>"xxxxxx_project_id_xxxxxxx",
        "access"=>"xxxxxx_access_id_xxxxxx1",
        "secret"=>"xxxxxx_secret_id_xxxxxx1",
        "trust_id"=>nil,
        "links"=>{
          "self"=>"https://identity_v3_url/users/xxxxxx_user_id_xxxxxxx/credentials/OS-EC2/xxxxxx_access_id_xxxxxxx"
        },
        "id"=>nil
      }
    end

    def ec2_creds_collection
      [{
        "user_id"=>"xxxxxx_user_id_xxxxxxx",
        "tenant_id"=>"xxxxxx_project_id_xxxxxxx",
        "access"=>"xxxxxx_access_id_xxxxxx1",
        "secret"=>"xxxxxx_secret_id_xxxxxx1",
        "trust_id"=>nil,
        "links"=>{
          "self"=>"https://identity_v3_url/users/xxxxxx_user_id_xxxxxxx/credentials/OS-EC2/xxxxxx_access_id_xxxxxx1"
        },
        "id"=>nil
      },
      {
        "user_id"=>"xxxxxx_user_id_xxxxxxx",
        "tenant_id"=>"xxxxxx_project_id_xxxxxx2",
        "access"=>"xxxxxx_access_id_xxxxxx2",
        "secret"=>"xxxxxx_secret_id_xxxxxx2",
        "trust_id"=>nil,
        "links"=>{
          "self"=>"https://identity_v3_url/users/xxxxxx_user_id_xxxxxxx/credentials/OS-EC2/xxxxxx_access_id_xxxxxx2"
        },
        "id"=>nil
      }]
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

    def formatted_email_opts
      {
        source: "ninenine@verizon.net.dk", # required
        destination: { # required
          to_addresses: ["curly@comcast.net, plover@me.com, jmcnamara@icloud.com"],
          cc_addresses: ["jaesenj@yahoo.ca,cgcra@yahoo.com, guialbu@msn.com"],
          bcc_addresses: ["policies@att.net,froodian@hotmail.com, fmerges@att.net"],
        },
        message: { # required
          subject: { # required
            data: "Winner Notification", # required
            charset: "UTF-8",
          },
          body: { # required
            text: {
              data: "<h1> Winner Notification </h1><br><p>The winner is ...</p>", # required
              charset: "UTF-8",
            },
            html: {
              data: " Winner Notification. The winner is ...", # required
              charset: "UTF-8",
            },
          },
        },
        reply_to_addresses: ["klm@yur.kr", "rjuhu@hyrtyd.co.uk"],
        return_path: "Address",
        source_arn: "AmazonResourceName",
        return_path_arn: "AmazonResourceName",
        tags: [
          {
            name: "MessageTagName", # required
            value: "MessageTagValue", # required
          },
        ],
        configuration_set_name: "ConfigurationSet1",
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

    def custom_verification_email_template_opts
      {
        id: 201,
        template_name: "TemplateName",
        from_email_address: "abc@def.com",
        template_subject: "Subject",
        template_content: "TemplateContent",
        success_redirection_url: "https://abc.com/v1/path/1",
        failure_redirection_url: "https://abc.com/v1/path/2",
      }
    end

    def template_replacement_json
      return
        {
          "meta":{
            "userId":"575132908"
          },
          "contact":{
            "firstName":"Michael",
            "lastName":"Jackson",
            "city":"Texas",
            "country":"USA",
            "postalCode":"78974"
          },
          "subscription":[
            {
              "interest":"Sports"
            },
            {
              "interest":"Travel"
            },
            {
              "interest":"Cooking"
            }
          ]
        }
    end

    def configset_opts
      {
        id: 0,
        name: "NewConfigSet"
      }
    end

  end

end
