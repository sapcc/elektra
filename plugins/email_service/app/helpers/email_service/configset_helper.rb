module EmailService
  module ConfigsetHelper
    include AwsSesHelper
    # include PlainEmailHelper
    # include TemplatedEmailHelper

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
      status = ""
      begin
        ses_client = create_ses_client
        resp = ses_client.create_configuration_set({
          configuration_set: { # required
            name: configset.name, # required
          },
        })
        audit_logger.info(current_user, 'has created configset', configset.name)
        status = "success" 
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: SAVE CONFIGSET: #{error}"
      end
      status
    end

    def delete_configset(name)
      status = ""
      begin
        ses_client = create_ses_client
        resp = ses_client.delete_configuration_set({
              configuration_set_name: name,
        })
        msg = "Configset #{name} is deleted."
        audit_logger.info(current_user, 'has deleted configset', name)
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        msg = "Unable to delete Configset #{name}. Error message: #{error} "
        status = msg
        logger.debug "CRONUS: DEBUG: DELETE CONFIGSET: #{error}"
      end
      status
    end


    def list_configsets(token="")
      configset_hash = Hash.new
      configsets = []
      begin
        ses_client = create_ses_client
        resp = ses_client.list_configuration_sets({
          next_token: "",
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
      return next_token, configsets && !configsets.empty? ? configsets : error
    end

    def list_configset_names(token="")
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
