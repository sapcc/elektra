module EmailService
  module ConfigsetHelper
    include AwsSesHelper

    # https://docs.aws.amazon.com/sdk-for-ruby/v2/api/Aws/SES/Client.html#update_configuration_set_event_destination-instance_method
    
    def is_unique(name)
      configset = find_configset(name)
      if configset.name == name
        return false
      else
        return true
      end
    end

    def store_configset(configset)
      ses_client = create_ses_client # Aws::SES::Client or "ERROR Message"
      if ses_client.class == Aws::SES::Client
        begin
          # empty response on success #<struct Aws::SES::Types::CreateConfigurationSetResponse>
          resp = ses_client.create_configuration_set({
            configuration_set: { # required
              name: configset.name, # required
            },
          })
          audit_logger.info(current_user.id, 'has created configset', configset.name)
          status = "success" 
        rescue Aws::SES::Errors::ServiceError => error
          status = "#{error}"
          logger.debug "CRONUS: DEBUG: SAVE CONFIGSET: #{error}"
        end
        return status
      else
        return ses_client
      end
    end

    def delete_configset(name)
      ses_client = create_ses_client # Aws::SES::Client or "ERROR Message"
      if ses_client.class == Aws::SES::Client
        begin
          ses_client = create_ses_client
          resp = ses_client.delete_configuration_set({
                configuration_set_name: name,
          })
          audit_logger.info(current_user.id, 'has deleted configset', name)
          status = "success"
        rescue Aws::SES::Errors::ServiceError => error
          msg = "Unable to delete Configset #{name}. Error message: #{error} "
          status = msg
          logger.debug "CRONUS: DEBUG: DELETE CONFIGSET: #{error}"
        end
        return status
      else
        return ses_client
      end
    end


    def list_configsets(token=nil)
      configset_hash = Hash.new
      configsets = []
      next_token = nil
      ses_client = create_ses_client
      if ses_client.class == Aws::SES::Client
        begin
          # lists 1000 items
          resp = ses_client.list_configuration_sets({
            next_token: token,
            max_items: 1000,
          })
          next_token = resp.next_token
          for index in 0 ... resp.configuration_sets.size
            configset_hash = { 
                :id => index,
                :name => resp.configuration_sets[index].name
              }
            configsets.push(configset_hash)
          end if resp.configuration_sets.size > 0
        rescue Aws::SES::Errors::ServiceError => error
          status = "#{error}"
          logger.debug "CRONUS: DEBUG: LIST CONFIGSETS: #{error}"
        end
      else
        error = ses_client
      end
      return next_token, configsets && !configsets.empty? ? configsets : error
    end

    def list_configset_names(token=nil)
      configset_names = []
      _, configsets = list_configsets(token)
      configsets.each do | cfg |
        configset_names << cfg[:name]
      end if configsets && !configsets.empty?
      configset_names      
    end

    # Find existing config set
    def find_configset(name)
      _, configsets = list_configsets
      configset = new_configset({})
      configsets.each do |cfg|
        if cfg[:name] == name 
          configset = new_configset(cfg)
          return configset
        end
      end
    end

    def describe_configset(name)
      ses_client = create_ses_client
      if ses_client.class == Aws::SES::Client
        begin
          ses_client = create_ses_client
          resp = ses_client.describe_configuration_set({
            configuration_set_name: name, # required
            configuration_set_attribute_names: ["eventDestinations"], # accepts eventDestinations, trackingOptions, deliveryOptions, reputationOptions
          })
        rescue Aws::SES::Errors::ServiceError => error
          status = "#{error}"
          logger.debug "CRONUS: DEBUG: DESCRIBE CONFIGSET: #{error}"
        end
        return resp
      else
        return ses_client
      end
    end

    def matching_event_types_collection 
      ["send", "reject", "bounce", "complaint", "delivery", "open", "click", "renderingFailure"]
    end

    def dimension_value_source_collection
      ["messageTag", "emailHeader", "linkTag"]
    end

    def configuration_set_attribute_names
      ["eventDestinations", "trackingOptions", "deliveryOptions", "reputationOptions"]
    end

  end
end
