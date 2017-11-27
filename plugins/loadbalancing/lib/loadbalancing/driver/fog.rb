module Loadbalancing
  module Driver
    # Compute calls
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper
      attr_reader :available

      def initialize(params)
        super(params)
        @fog = ::Fog::Network::OpenStack.new(auth_params)
        @available = true
      rescue ::Fog::OpenStack::Errors::ServiceUnavailable
        @fog = nil
        @available = false
      end


      ###################### LOADBALANCERS #######################
      def loadbalancers(filter = {})
        handle_response { @fog.list_lbaas_loadbalancers(filter).body['loadbalancers'] }
      end

      def get_loadbalancer(id)
        handle_response { @fog.get_lbaas_loadbalancer(id).body['loadbalancer'] }
      end

      def get_loadbalancer_hosting_agent(id)
        handle_response { @fog.get_lbaas_loadbalancer_hosting_agent(id).body['agent'] }
      end

      def create_loadbalancer(attributes={})
        vip_subnet_id = attributes.delete("vip_subnet_id")
        handle_response { @fog.create_lbaas_loadbalancer(vip_subnet_id, attributes).body['loadbalancer'] }
      end

      def update_loadbalancer(id, attributes={})
        handle_response{ @fog.update_lbaas_loadbalancer(id, attributes).body['loadbalancer'] }
      end

      def delete_loadbalancer(loadbalancer_id)
        handle_response { @fog.delete_lbaas_loadbalancer(loadbalancer_id) }
      end

      def get_loadbalancer_statuses(loadbalancer_id)
        handle_response { @fog.get_lbaas_loadbalancer_statuses(loadbalancer_id).body['statuses'] }
      end

      def listeners(filter = {})
        handle_response { @fog.list_lbaas_listeners(filter).body['listeners'] }
      end

      def get_listener(id)
        handle_response { @fog.get_lbaas_listener(id).body['listener'] }
      end

      def create_listener(attributes={})
        loadbalancer_id = attributes.delete("loadbalancer_id")
        protocol = attributes.delete("protocol")
        protocol_port = attributes.delete("protocol_port")
        handle_response { @fog.create_lbaas_listener(loadbalancer_id, protocol, protocol_port, attributes).body['listener'] }
      end

      def update_listener(id, attributes={})
        handle_response{ @fog.update_lbaas_listener(id, attributes).body['listener'] }
      end

      def delete_listener(listener_id)
        handle_response { @fog.delete_lbaas_listener(listener_id) }
      end

      def pools(filter = {})
        handle_response { @fog.list_lbaas_pools(filter).body['pools'] }
      end

      def get_pool(id)
        handle_response { @fog.get_lbaas_pool(id).body['pool'] }
      end

      def create_pool(attributes={})
        listener_id = attributes.delete("listener_id")
        protocol = attributes.delete("protocol")
        lb_algorithm = attributes.delete("lb_algorithm")
        handle_response { @fog.create_lbaas_pool(listener_id, protocol, lb_algorithm, attributes).body['pool'] }
      end

      def update_pool(id, attributes={})
        handle_response{ @fog.update_lbaas_pool(id, attributes).body['pool'] }
      end

      def delete_pool(id)
        handle_response { @fog.delete_lbaas_pool(id) }
      end

      def pool_members(filter = {})
        handle_response { @fog.list_lbaas_pool_members(filter).body['members'] }
      end

      def get_pool_member(pool_id, member_id)
        handle_response { @fog.get_lbaas_pool_member(pool_id, member_id).body['member'] }
      end

      def create_pool_member(attributes={})
        pool_id = attributes.delete("pool_id")
        address = attributes.delete("address")
        protocol_port = attributes.delete("protocol_port")
        handle_response { @fog.create_lbaas_pool_member(pool_id, address, protocol_port, attributes).body['member'] }
      end

      def delete_pool_member(pool_id, member_id)
        handle_response { @fog.delete_lbaas_pool_member(pool_id, member_id) }
      end

      def healthmonitors(filter = {})
        handle_response { @fog.list_lbaas_healthmonitors(filter).body['healthmonitors'] }
      end

      def get_healthmonitor(id)
        handle_response { @fog.get_lbaas_healthmonitor(id).body['healthmonitor'] }
      end

      def create_healthmonitor(attributes={})
        pool_id = attributes.delete("pool_id")
        type = attributes.delete("type")
        delay = attributes.delete("delay")
        timeout = attributes.delete("timeout")
        max_retries = attributes.delete("max_retries")
        handle_response { @fog.create_lbaas_healthmonitor(pool_id, type, delay, timeout, max_retries,attributes).body['healthmonitor'] }
      end

      def update_healthmonitor(id, attributes={})
        handle_response{ @fog.update_lbaas_healthmonitor(id, attributes).body['healthmonitor'] }
      end

      def delete_healthmonitor(healthmonitor_id)
        handle_response { @fog.delete_lbaas_healthmonitor(healthmonitor_id) }
      end

      ###################### L7 POLICIES and L7 RULES #######################

      def l7policies(filter = {})
        handle_response { @fog.list_lbaas_l7policies(filter).body['l7policies'] }
      end

      def get_l7policy(id)
        handle_response { @fog.get_lbaas_l7policy(id).body['l7policy'] }
      end

      def create_l7policy(attributes={})
        listener_id = attributes.delete("listener_id")
        action = attributes.delete("action")
        handle_response { @fog.create_lbaas_l7policy(listener_id, action, attributes).body['l7policy'] }
      end

      def update_l7policy(id, attributes={})
        handle_response{ @fog.update_lbaas_l7policy(id, attributes).body['l7policy'] }
      end

      def delete_l7policy(id)
        handle_response { @fog.delete_lbaas_l7policy(id) }
      end


      def l7rules(l7policy_id, filter = {})
        handle_response { @fog.list_lbaas_l7rules(l7policy_id, filter).body['rules'] }
      end

      def get_l7rule(policy_id, id)
        handle_response { @fog.get_lbaas_l7rule(policy_id, id).body['rule'] }
      end

      def create_l7rule(attributes={})
        l7policy_id = attributes.delete("l7policy_id")
        type = attributes.delete("type")
        compare_type = attributes.delete("compare_type")
        value = attributes.delete("value")
        handle_response { @fog.create_lbaas_l7rule(l7policy_id, type, compare_type, value, attributes).body['rule'] }
      end

      def update_l7rule(l7policy_id, id, attributes={})
        handle_response{ @fog.update_lbaas_l7rule(l7policy_id, id, attributes).body['rule'] }
      end

      def delete_l7rule(l7policy_id, id)
        handle_response { @fog.delete_lbaas_l7rule(l7policy_id, id) }
      end

    end
  end
end