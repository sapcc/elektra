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

      def handle_api_errors?
        # to handle the errors withing the plugin (inside the application_controller)
        # otherwise all errors will be swallowed by the service layer
        false
      end

      def alarm_definitions
        handle_response do
          @fog.list_alarm_definitions.body["elements"]
        end
      end

      def alarms(options = {})
        handle_response do
          @fog.list_alarms(options).body["elements"]
        end
      end

      def get_alarm(id)
        handle_response do
          # TODO: remove options?
          @fog.get_alarm(id,{}).body
        end
      end

      def get_alarm_definition(id)
        handle_response do
          @fog.get_alarm_definition(id).body
        end
      end

      def get_notification_method(id)
        handle_response do
          @fog.get_notification_method(id).body
        end
      end

      def delete_notification_method(id)
        handle_response do
          @fog.delete_notification_method(id).body
        end
      end

      def update_notification_method(id, params={})
        handle_response do
          # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#request-body-10
          request_params = {
            "name" => params["name"],
            "type" => params["type"], 
            "address" => params["address"],
          }
          @fog.update_notification_method(id, request_params).body
        end
      end

      def update_alarm_definition(id, params={})
        # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#request-body-15
        # TODO: if the alarm definition was created with no match_by it cannot be updated and hangs with message
        #       "match_by must not change"
        request_params = {
          "name"        => params["name"],
          "description" => params["description"], 
          "expression"  => params["expression"], 
          "severity"    => params["severity"], 
          "match_by"    => params["match_by"],
        }
 
        # needed when update_attributes(attr) is used and no "match_by" was given
        # then match_by is already set with the current value and do not need converted
        unless request_params["match_by"].kind_of?(Array)
          request_params["match_by"]=  params["match_by"].split(', ')
        end

        if params['actions_enabled'] == '1' or params['actions_enabled'] == true
          request_params['actions_enabled'] = true
        else  
          request_params['actions_enabled'] = false
        end
        request_params['ok_actions'] = params['ok_actions'] 
        request_params['alarm_actions'] = params['alarm_actions']
        request_params['undetermined_actions'] = params['undetermined_actions'] 

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

      def create_notification_method(params={})
        # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#request-body-7
        handle_response do
          @fog.create_notification_method(params).body
        end
      end

      def create_alarm_definition(params={})
        # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#request-body-12
        # not allowed paramters are deleted here
        params.delete('actions_enabled')
        # handle comma seperated list
        params["match_by"] = params["match_by"].split(',')
        handle_response do
          @fog.create_alarm_definition(params).body
        end
      end
    end
  end
end


