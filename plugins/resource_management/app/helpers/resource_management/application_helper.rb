module ResourceManagement
  module ApplicationHelper

    def calculate_quotas(usage, approved_quota, real_quota)
       @custom_quota = approved_quota != real_quota 
       @approved_quota_rest = approved_quota - usage
       if @approved_quota_rest > 0
         @real_quota_rest = real_quota - approved_quota
       else
         @real_quota_rest = real_quota - usage
       end
      # percent calc
       real_percent = real_quota/100.0
       @real_usage_percent = usage/real_percent
       @approved_quota_rest_percent = @approved_quota_rest/real_percent
       @real_quota_rest_percent = @real_quota_rest/real_percent
       @usage_percent_with_overcommit = usage/(approved_quota/100)
       @softlimit_usage_percent = @usage_percent_with_overcommit - 100
 
    end

  end
end
