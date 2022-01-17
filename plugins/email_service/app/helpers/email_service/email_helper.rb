module EmailService
  module EmailHelper
    include AwsSesHelper
    include PlainEmailHelper
    include TemplatedEmailHelper

    def new_email(attributes = {})
      email = PlainEmail.new(attributes)
    end

    def new_templated_email(attributes = {})
      email = TemplatedEmail.new(attributes)
    end


    # create an array of valid email addresses
    def addr_validate(raw_addr)
      unless raw_addr.empty?
        values = raw_addr.split(",")
        addr = []
        values.each do |value|
          addr << value.strip
        end
        return addr
      end
      return []
    end

    def email_to_array(email_item)
      email_item.email.to_addr= addr_validate(email_item.email.to_addr)
      email_item.email.cc_addr= addr_validate(email_item.email.cc_addr)
      email_item.email.bcc_addr = addr_validate(email_item.email.bcc_addr)
      email_item
    end

    
    def send_email(plain_email)
      error = ""
      begin
        ses_client = create_ses_client
        resp = ses_client.send_email(
          destination: {
            to_addresses: plain_email.to_addr ,
            cc_addresses: plain_email.cc_addr ,
            bcc_addresses: plain_email.bcc_addr,
          },
          message: {
            body: {
              html: {
                charset: @encoding,
                data: plain_email.htmlbody
              },
              text: {
                charset: @encoding,
                data: plain_email.textbody
              }
            },
            subject: {
              charset: @encoding,
              data: plain_email.subject
            }
          },
          source: plain_email.source,
        )
        audit_logger.info(current_user, 'has sent email to', plain_email.to_addr,plain_email.cc_addr, plain_email.bcc_addr)
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "CRONUS : ERROR: Send Plain eMail -#{plain_email.inspect} :-:  #{error}"
      end
      resp && resp.successful? ? "success" : error
    end

    def send_templated_email(templated_email)
      error = ""
      resp = ""
      begin
        ses_client = create_ses_client
        resp = ses_client.send_templated_email({
          source: templated_email.source, 
          destination: {
            to_addresses: templated_email.to_addr,
            cc_addresses: templated_email.cc_addr,
            bcc_addresses: templated_email.bcc_addr,
          },
          reply_to_addresses: [templated_email.reply_to_addr],
          return_path: templated_email.reply_to_addr,
          tags: [
            {
              name: "MessageTagName", 
              value: "MessageTagValue",
            },
          ],
          configuration_set_name: templated_email.configset_name,
          template: templated_email.template_name, 
          template_data: templated_email.template_data,
        })
        audit_logger.info(current_user, 'has sent templated email from the template', \
        templated_email.template_name,  'to', templated_email.to_addr, \
        templated_email.cc_addr, templated_email.bcc_addr)
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "CRONUS: DEBUG: #{error}"
      end
      resp && resp.successful? ? "success" : error
    end
    
  end
end


