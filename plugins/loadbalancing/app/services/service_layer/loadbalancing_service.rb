module ServiceLayer

  class LoadbalancingService < Core::ServiceLayer::Service

    def driver
      @driver ||= Loadbalancing::Driver::Fog.new({
                                                     auth_url: self.auth_url,
                                                     region: self.region,
                                                     token: self.token,
                                                     domain_id: self.domain_id,
                                                     project_id: self.project_id
                                                 })
    end

    def available?(action_name_sym=nil)
      not current_user.service_url('network', region: region).nil?
    end

    def test
      driver.test
    end

    def loadbalancers(filter={})
      driver.map_to(Loadbalancing::Loadbalancer).loadbalancers(filter)
    end

    def find_loadbalancer(id)
      driver.map_to(Loadbalancing::Loadbalancer).get_loadbalancer(id)
    end

    def get_loadbalancer_hosting_agent(id)
      driver.map_to(Loadbalancing::Loadbalancer).get_loadbalancer_hosting_agent(id)
    end

    def new_loadbalancer(attributes={})
      Loadbalancing::Loadbalancer.new(driver, attributes)
    end

    def loadbalancer_statuses(id)
      driver.map_to(Loadbalancing::Statuses).get_loadbalancer_statuses(id)
    end

    def listeners(filter={})
      driver.map_to(Loadbalancing::Listener).listeners(filter)
    end

    def find_listener(listener_id)
      driver.map_to(Loadbalancing::Listener).get_listener(listener_id)
    end

    def new_listener(attributes={})
      Loadbalancing::Listener.new(driver, attributes)
    end

    def pools(filter={})
      driver.map_to(Loadbalancing::Pool).pools(filter)
    end

    def find_pool(pool_id)
      driver.map_to(Loadbalancing::Pool).get_pool(pool_id)
    end

    def new_pool(attributes={})
      Loadbalancing::Pool.new(driver, attributes)
    end

    def pool_members(filter={})
      driver.map_to(Loadbalancing::PoolMember).pool_members(filter)
    end

    def find_pool_member(pool_id, member_id)
      driver.map_to(Loadbalancing::PoolMember).get_pool_member(pool_id, member_id)
    end

    def delete_pool_member(pool_id, member_id)
      driver.map_to(Loadbalancing::PoolMember).delete_pool_member(pool_id, member_id)
    end

    def new_pool_member(attributes={})
      Loadbalancing::PoolMember.new(driver, attributes)
    end

    def healthmonitors(filter={})
      driver.map_to(Loadbalancing::Healthmonitor).healthmonitors(filter)
    end

    def find_healthmonitor(healthmonitor_id)
      driver.map_to(Loadbalancing::Healthmonitor).get_healthmonitor(healthmonitor_id)
    end

    def new_healthmonitor(attributes={})
      Loadbalancing::Healthmonitor.new(driver, attributes)
    end

    def l7policies(filter={})
      driver.map_to(Loadbalancing::L7policy).l7policies(filter)
    end

    def find_l7policy(l7policy_id)
      driver.map_to(Loadbalancing::L7policy).get_l7policy(l7policy_id)
    end

    def new_l7policy(attributes={})
      Loadbalancing::L7policy.new(driver, attributes)
    end

    def l7rules(l7policy_id, filter={})
      driver.map_to(Loadbalancing::L7rule).l7rules(l7policy_id, filter)
    end

    def find_l7rule(l7policy_id, l7rule_id)
      driver.map_to(Loadbalancing::L7rule).get_l7rule(l7policy_id, l7rule_id)
    end

    def delete_l7rule(l7policy_id, l7rule_id)
      driver.map_to(Loadbalancing::L7rule).delete_l7rule(l7policy_id, l7rule_id)
    end

    def update_l7rule(l7policy_id, l7rule_id, attributes={})
      driver.map_to(Loadbalancing::L7rule).update_l7rule(l7policy_id, l7rule_id, attributes)
    end

    def new_l7rule(attributes={})
      Loadbalancing::L7rule.new(driver, attributes)
    end

    def loadbalancer_changeable?(id, block_source)
      status = loadbalancer_statuses(id).find_state(id).provisioning_status rescue nil
      return false unless status
      count = 0
      until ['ACTIVE', 'ERROR'].include?(status)
        if count >= 6*2
          return false
        else
          count += 1
          Rails.logger.warn "Loadbalancer in state: #{status}. Waiting for action execution of #{block_source} for #{10*count} seconds in total."
          sleep 10
          status = loadbalancer_statuses(id).find_state(id).provisioning_status rescue nil
          return false unless status
        end
      end
      return true
    end

    def execute(id, &block)
      if loadbalancer_changeable?(id, block.source)
        return block.call
      else
        return false
      end
    end

  end
end