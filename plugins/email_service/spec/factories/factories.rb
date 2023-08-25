module EmailService
  class FakeFactory
    def plain_email
      EmailService::Forms::PlainEmail.new(plain_email_opts)
    end

    def templated_email
      EmailService::Forms::TemplatedEmail.new(templated_email_opts)
    end

    def custom_verification_email_template
      EmailService::Forms::CustomVerificationEmailTemplate.new(
        custom_verification_email_template_opts
      )
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
      domain_signing_selector = 'some_selector'
      domain_signing_private_key = 'domain_signing_private_key'
      next_signing_key_length = 'RSA_1024_BIT'
      {
        id: '000002',
        identity: 'identity.domain',
        domain_name: 'abc.def',
        dkim_enabled: true,
        dkim_signing_attributes: {
          'domain_signing_selector' => domain_signing_selector,
          'domain_signing_private_key' => domain_signing_private_key,
          'next_signing_key_length' => next_signing_key_length
        },
        tags: [{ 'key1' => 'value1' }, { 'key2' => 'value2' }],
        configuration_set_name: 'configset_domain_name'
      }
    end

    def verified_email_opts
      domain_signing_selector = 'some_selector'
      domain_signing_private_key = 'domain_signing_private_key'
      next_signing_key_length = 'RSA_1024_BIT'
      {
        id: '000001',
        identity: 'identity.email',
        domain_name: 'abc.def',
        dkim_enabled: true,
        dkim_signing_attributes: {
          'domain_signing_selector' => domain_signing_selector,
          'domain_signing_private_key' => domain_signing_private_key,
          'next_signing_key_length' => next_signing_key_length
        },
        tags: [{ 'key1' => 'value1' }, { 'key2' => 'value2' }],
        configuration_set_name: 'configset_email_name'
      }
    end

    def rsa_key_length
      @rsa_key_length = 'RSA_1024_BIT'
    end

    def configsets_collection
      @configsets_collection = %w[configset1 configset2]
    end

    def ec2_creds
      {
        'user_id' => 'xxxxxx_user_id_xxxxxx',
        'tenant_id' => 'xxxxxx_project_id_xxxxxxx',
        'access' => 'xxxxxx_access_id_xxxxxx1',
        'secret' => 'xxxxxx_secret_id_xxxxxx1',
        'trust_id' => nil,
        'links' => {
          'self' =>
            'https://identity_v3_url/users/xxxxxx_user_id_xxxxxxx/credentials/OS-EC2/xxxxxx_access_id_xxxxxxx'
        },
        'id' => nil
      }
    end

    def ec2_creds_collection
      [
        {
          'user_id' => 'xxxxxx_user_id_xxxxxxx',
          'tenant_id' => 'xxxxxx_project_id_xxxxxxx',
          'access' => 'xxxxxx_access_id_xxxxxx1',
          'secret' => 'xxxxxx_secret_id_xxxxxx1',
          'trust_id' => nil,
          'links' => {
            'self' =>
              'https://identity_v3_url/users/xxxxxx_user_id_xxxxxxx/credentials/OS-EC2/xxxxxx_access_id_xxxxxx1'
          },
          'id' => nil
        },
        {
          'user_id' => 'xxxxxx_user_id_xxxxxxx',
          'tenant_id' => 'xxxxxx_project_id_xxxxxx2',
          'access' => 'xxxxxx_access_id_xxxxxx2',
          'secret' => 'xxxxxx_secret_id_xxxxxx2',
          'trust_id' => nil,
          'links' => {
            'self' =>
              'https://identity_v3_url/users/xxxxxx_user_id_xxxxxxx/credentials/OS-EC2/xxxxxx_access_id_xxxxxx2'
          },
          'id' => nil
        }
      ]
    end

    def plain_email_opts
      {
        source: 'abc@def.com',
        to_addr: 'abc@def.com, ghi@rbss.de',
        cc_addr: 'klm@yur.kr, rjuhu@hyrtyd.co.uk',
        bcc_addr: 'abc@xyz.mn.rb, kd@mr.jq.lk',
        subject: 'Sample Subject',
        htmlbody:
          '<html><head><title>TEST</title><body><h1>Body of the HTML email<h1></body></html>',
        textbody: 'Body of the PLAIN email'
      }
    end

    def formatted_email_opts
      {
        source: 'ninenine@verizon.net.dk',
        destination: {
          to_addresses: [
            'curly@comcast.net, plover@me.com, jmcnamara@icloud.com'
          ],
          cc_addresses: ['jaesenj@yahoo.ca,cgcra@yahoo.com, guialbu@msn.com'],
          bcc_addresses: [
            'policies@att.net,froodian@hotmail.com, fmerges@att.net'
          ]
        },
        message: {
          subject: {
            data: 'Winner Notification',
            charset: 'UTF-8'
          },
          body: {
            text: {
              data:
                '<h1> Winner Notification </h1><br><p>The winner is ...</p>',
              charset: 'UTF-8'
            },
            html: {
              data: ' Winner Notification. The winner is ...',
              charset: 'UTF-8'
            }
          }
        },
        reply_to_addresses: %w[klm@yur.kr rjuhu@hyrtyd.co.uk],
        return_path: 'Address',
        source_arn: 'AmazonResourceName',
        return_path_arn: 'AmazonResourceName',
        tags: [
          {
            name: 'MessageTagName',
            value: 'MessageTagValue'
          }
        ],
        configuration_set_name: 'ConfigurationSet1'
      }
    end

    def template_opts
      {
        id: 0,
        name: 'new template',
        subject: 'Subject of the new template',
        html_part: '<h1>HTML Content of the Email </h1>',
        text_part: 'Content of the Email'
      }
    end

    def templated_email_opts
      {
        source: 'abc@def.com',
        to_addr: 'abc@def.com, ghi@rbss.de',
        cc_addr: 'klm@yur.kr, rjuhu@hyrtyd.co.uk',
        bcc_addr: 'abc@xyz.mn.rb, kd@mr.jq.lk',
        template_name: 'MyTemplate',
        template_data: '{ "abc": { "def": "klm"}}',
        configset: 'MyConfigSet'
      }
    end

    def custom_verification_email_template_opts
      {
        id: 201,
        template_name: 'TemplateName',
        from_email_address: 'abc@def.com',
        template_subject: 'Subject',
        template_content: 'TemplateContent',
        success_redirection_url: 'https://abc.com/v1/path/1',
        failure_redirection_url: 'https://abc.com/v1/path/2'
      }
    end

    def template_replacement_json
      return
      {
        meta: {
          userId: '575132908'
        },
        contact: {
          firstName: 'Michael',
          lastName: 'Jackson',
          city: 'Texas',
          country: 'USA',
          postalCode: '78974'
        },
        subscription: [
          { interest: 'Sports' },
          { interest: 'Travel' },
          { interest: 'Cooking' }
        ]
      }
    end

    def configset_opts
      {
        id: 0,
        name: 'NewConfigSet',
        tls_policy: 'tls_policy',
        custom_redirect_domain: 'custom_redirect_domain',
        sending_pool_name: 'sending_pool_name',
        reputation_metrics_enabled: true,
        last_fresh_start: '', # DateTime
        sending_enabled: true,
        tags: %w[valid tag list],
        suppressed_reasons: %w[reason1 reason2]
      }
    end

    # Test cases in PROGRESS
    def terminated_response
      { error: 'failed to get a Nebula account status: account is marked as terminated' }
    end

    def not_activated_response
      { error: 'failed to get a Nebula account status: account isn\'t activated' }
    end

    def pending_customer_action_response
      { status: 'PENDING-CUSTOMER-ACTION',
        details: "Hello,\n\n\nThank you for submitting your request to increase your sending limits. We would like to gather more information about your use case.\n\nIf you can provide additional information about how you plan to use Amazon SES, we will review the information to understand how you are sending and we can recommend best practices to improve your sending experience. In your response, include as much detail as you can about your email-sending processes and procedures.\n\nFor example, tell us how often you send email, how you maintain your recipient lists, and how you manage bounces, complaints, and unsubscribe requests. It is also helpful to provide examples of the email you plan to send so we can ensure that you are sending high-quality content that recipients will want to receive.\n\nYou can provide this information by replying to this message. Our team provides an initial response to your request within 24 hours. If we're able to do so, we'll grant your request within this 24-hour period. However, we may need to obtain additional information from you and it might take longer to resolve your request.\n\nThank you for contacting Amazon Web Services.\n\n", security_attributes: 'security officer John Doe (IXXXXXX), environment DEV, valid until YYYY-MM-DD', compliant: true }
    end

    def pending_response
      { status: 'PENDING',
        security_attributes: 'security officer John Doe (IXXXXXX), environment DEV, valid until YYYY-MM-DD', compliant: true }
    end

    def denied_response
      { status: 'DENIED',
        security_attributes: 'security officer John Doe (IXXXXXX), environment DEV, valid until YYYY-MM-DD', compliant: true }
    end

    def customer_action_completed_response
      { status: 'CUSTOMER-ACTION-COMPLETED',
        security_attributes: 'security officer John Doe (IXXXXXX), environment DEV, valid until YYYY-MM-DD', compliant: true }
    end

    def sandbox_response
      { production: nil, status: 'GRANTED',
        security_attributes: 'security officer John Doe (IXXXXXX), environment DEV, valid until YYYY-MM-DD', compliant: true }
    end

    def production_response
      { production: 'true', status: 'GRANTED',
        security_attributes: 'security officer John Doe (IXXXXXX), environment DEV, valid until YYYY-MM-DD', compliant: true }
    end
  end
end
