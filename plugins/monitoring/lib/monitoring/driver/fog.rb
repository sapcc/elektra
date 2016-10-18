module Monitoring
  module Driver
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

      def initialize(params_or_driver)
        # support initialization by given driver
        if params_or_driver.is_a?(::Fog::Monitoring::OpenStack)
          @fog = params_or_driver
        else
          super(params_or_driver)
          # don't include useless request/response dumps in exception messages
          no_debug = { debug: false, debug_request: false, debug_response: false}
          @fog = ::Fog::Monitoring::OpenStack.new(auth_params.merge(connection_options: no_debug))
        end
      end

      def alarm_definitions
        handle_response do
          @fog.list_alarm_definitions.body["elements"]
        end
      end
      
      def list_metrics(options={})
        handle_response do
          @fog.list_metrics(options).body["elements"]
        end
      end

      def list_metric_names(options={})
        handle_response do
          @fog.list_metric_names(options).body["elements"]
        end
      end

      def list_statistics(options={})
        handle_response do
          @fog.list_statistics(options).body["elements"]
        end
      end

      def alarms(options={})
        handle_response do
          @fog.list_alarms(options).body["elements"]
        end
      end

      def alarm_states_history(id, options={})
        handle_response do
          @fog.list_alarm_state_history_for_specific_alarm(id, options).body["elements"]
        end
      end

      def get_alarm(id)
        handle_response do
          @fog.get_alarm(id).body
        end
      end

      def get_alarm_definition(id)
        handle_response do
          begin 
            @fog.get_alarm_definition(id).body
          rescue ::Fog::Monitoring::OpenStack::NotFound
            # is handled in alarm_defintions_controller -> load_alarm_definition()
            # get_alarm_definition is loaded before delete and update so we only 
            # need to take care in one place
            false
          end
        end
      end

      def get_notification_method(id)
        handle_response do
          begin
            @fog.get_notification_method(id).body
          rescue ::Fog::Monitoring::OpenStack::NotFound
            # is handled in notification_methods_controller -> load_notification_method()
            # get_notification_method is loaded before delete and update so we only
            # need to take care in one place
            false
          end
         end
      end

      def delete_notification_method(id)
        handle_response do
          @fog.delete_notification_method(id).body
        end
      end

      def update_notification_method(id, options={})
        handle_response do
          # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#request-body-10
          request_params = {
            "name" => options["name"],
            "type" => options["type"], 
            "address" => options["address"],
          }
          @fog.update_notification_method(id, request_params).body
        end
      end

      def update_alarm_definition(id, options={})
        # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#request-body-15
        # TODO: if the alarm definition was created with no match_by it cannot be updated and hangs with message
        #       "match_by must not change"
        request_params = {
          "name"        => options["name"],
          "description" => options["description"], 
          "expression"  => options["expression"], 
          "severity"    => options["severity"], 
          "match_by"    => options["match_by"],
        }
 
        # needed when update_attributes(attr) is used and no "match_by" was given
        # then match_by is already set with the current value and do not need converted
        unless request_params["match_by"].kind_of?(Array)
          request_params["match_by"]=  options["match_by"].split(', ')
        end

        if options['actions_enabled'] == '1' or options['actions_enabled'] == true
          request_params['actions_enabled'] = true
        else  
          request_params['actions_enabled'] = false
        end
        request_params['ok_actions'] = options['ok_actions'] 
        request_params['alarm_actions'] = options['alarm_actions']
        request_params['undetermined_actions'] = options['undetermined_actions'] 

        handle_response do
          @fog.update_alarm_definition(id, request_params).body
        end
      end

      def delete_alarm_definition(id)
        handle_response do
          @fog.delete_alarm_definition(id).body
        end
      end

      def delete_alarm(id)
        handle_response do
          @fog.delete_alarm(id).body
        end
      end

      def notification_methods
        handle_response do
          @fog.list_notification_methods.body["elements"]
        end
      end

      def create_notification_method(options={})
        # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#request-body-7
        handle_response do
          @fog.create_notification_method(options).body
        end
      end

      def create_alarm_definition(options={})
        # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#request-body-12
        # not allowed paramters are deleted here
        options.delete('actions_enabled')
        # handle comma seperated list
        options["match_by"] = options["match_by"].split(',')
        handle_response do
          @fog.create_alarm_definition(options).body
        end
      end
      
      def list_dimension_values(dimension_values,options={})
        handle_response do
          @fog.list_dimension_values(dimension_values,options).body["elements"]
        end
      end
    end
  end
end


