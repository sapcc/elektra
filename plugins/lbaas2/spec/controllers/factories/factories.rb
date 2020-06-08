module Lbaas2

  class FakeFactory

    def loadbalancer(params = {})
      {vip_subnet_id: "456", vip_network_id: "123", name: "test lb"} 
    end

    def listener(params={})
      {name: "listener_test", protocol: "HTTP", protocol_port: "8080"}
    end

    def pool(params={})
      {name: "pool_test", lb_algorithm: "ROUND_ROBIN", protocol: "HTTP"}
    end

    def l7policy(params={})
      {name: "lypolicy_test", action: "REDIRECT_PREFIX"}
    end

    def l7rule(params={})
      {type: "PATH", value: "test_value", compare_type: "CONTAINS"}
    end

    def healthmonitor(params={})
      {name: "healthmonitor_test", type: "HTTP", delay: "10", max_retries: "5", timeout: "5"}
    end

    def update_healthmonitor(params={})
      {id: "update_test_healthmonitor", name: "healthmonitor_test", delay: "10", max_retries: "5", timeout: "5"}
    end

  end
end