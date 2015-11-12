class Dashboard::QuotasController < DashboardController

    def index
        @used_resources = {
            "ImageMeta"=>20, 
            "Personality"=>5, 
            "PersonalitySize"=>0, 
            "SecurityGroupRules"=>10, 
            "SecurityGroups"=>2, 
            "ServerGroupMembers"=>2, 
            "ServerGroups"=>4, 
            "ServerMeta"=>0, 
            "TotalCores"=>150, 
            "TotalFloatingIps"=>40,
            "TotalInstances"=>45,
            "TotalKeypairs"=>200,
            "TotalRAMSize"=>46080
        }

        # get limits for compute
        @limits_compute = services.compute.get_limits.body['limits']['absolute']
        @max_limits = {}
        @total_used = {}
        @limits_compute.keys.sort.each do |key|
          if key.match('max')
              max = @limits_compute[key]
              key = key.gsub('max','')
              current_use = @used_resources[key]
              persent_use = ((current_use.to_f / max.to_f) * 100).to_i
              #unless ( max == 0 or current_use == 0 )
              @max_limits[key] = { :limit => max, :used => current_use, :persent => persent_use }
          end
          if key.match('total')
              @total_used[key.gsub('total','')] = @limits_compute[key]
          end
        end
        puts @max_limits

        # get qotas for compute
        @quota_compute = services.compute.get_quota(@scoped_project_id).body['quota_set']
        @quota_compute.delete('id')
        puts @quota_compute

        #puts services
        # get qotas for network
        #@quota_network = services.network.get_quota(@scoped_project_id).body['quota_set']
        #@quota_network.delete('id')
        #puts @quota_newtork

        # get qotas for volume
        @quota_volume = services.volume.get_quota(@scoped_project_id).body['quota_set']
        @quota_volume.delete('id')
        puts @quota_volume


    end

end
