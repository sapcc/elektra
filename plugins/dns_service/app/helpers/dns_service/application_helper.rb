module DnsService
  module ApplicationHelper
    def pool_name_and_description(pool_id, pools = [])
      pool = select_pool(pool_id, pools)
      pool ? "#{pool.name} (#{pool.description})" : pool_id
    end

    def pool_name(pool_id, pools = [])
      pool = select_pool(pool_id, pools)
      pool ? pool.name : pool_id
    end

    private

    def select_pool(pool_id, pools = [])
      pools = services.dns_service.pools[:items] if current_user.is_allowed?(
        "dns_service:pool_list",
      ) and pools.empty?
      pools.find { |p| p.id == pool_id }
    end
  end
end
