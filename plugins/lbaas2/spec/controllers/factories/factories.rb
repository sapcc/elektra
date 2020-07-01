module Lbaas2

  class FakeFactory

    def loadbalancer(params = {})
      {vip_subnet_id: "456", vip_network_id: "123", name: "test lb"}.merge(params) 
    end

    def update_loadbalancer(params = {})
      {id: "update_loadbalancer", name: "test lb update"}.merge(params) 
    end

    def listener(params={})
      {name: "listener_test", protocol: "HTTP", protocol_port: "8080"}.merge(params)
    end

    def pool(params={})
      {name: "pool_test", lb_algorithm: "ROUND_ROBIN", protocol: "HTTP"}.merge(params)
    end

    def l7policy(params={})
      {name: "lypolicy_test", action: "REDIRECT_PREFIX"}.merge(params)
    end

    def l7rule(params={})
      {type: "PATH", value: "test_value", compare_type: "CONTAINS"}.merge(params)
    end

    def healthmonitor(params={})
      {name: "healthmonitor_test", type: "HTTP", delay: "10", max_retries: "5", timeout: "5"}.merge(params)
    end

    def update_healthmonitor(params={})
      {id: "update_test_healthmonitor", name: "healthmonitor_test", delay: "10", max_retries: "5", timeout: "5"}.merge(params)
    end

    def member(params={})
      {"member[member_858][index]"=>0, "member[member_858][name]"=>"bmc_test", "member[member_858][identifier]"=>"member_858", "member[member_858][address]"=>"10.180.0.240", "member[member_858][protocol_port]"=>"8889", "member[member_858][weight]"=>1, "member[member_858][tags]"=>["kak"]}.merge(params)
    end

    def member_params
      {"member_858"=>{"address"=>"10.180.0.240", "identifier"=>"member_858", "index"=>"0", "name"=>"bmc_test", "protocol_port"=>"8889", "tags"=>'["kak"]', "weight"=>"1"}}
    end

  end
end