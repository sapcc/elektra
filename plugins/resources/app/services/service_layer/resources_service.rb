# frozen_string_literal: true

module ServiceLayer
  class ResourcesService < Core::ServiceLayer::Service

    def available?(_action_name_sym = nil)
      elektron.service?('resources')
    end

    def elektron_resources
      @elektron_resources ||= elektron.service(
        'resources', path_prefix: '/v1', interface: 'public'
      )
    end

    def elektron_placement
      @elektron_placement ||= elektron.service(
        'placement', 
        interface: 'public',
        headers: { 'OpenStack-API-Version' => 'placement 1.17' }
      )
    end

    def list_resource_providers
      providers = elektron_placement.get('resource_providers')
      return providers.body['resource_providers'] || { 'resource_providers' => [] }
    end

    def list_resource_aggregates(path)
      aggregates = elektron_placement.get(path)
      list = aggregates.body['aggregates'] || []
      return list
    end

    def get_resource_provider_inventory(uuid)
      data = elektron_placement.get("resource_providers/#{uuid}/inventories")
      inventories = data.body['inventories'] || {}
      return inventories
    end

    def big_vm_available(uuid)
      big_vms = {}
      provider = elektron_placement.get("resource_providers/#{uuid}/inventories")
      reserved = provider.body['inventories']['CUSTOM_BIGVM']['reserved']
      if reserved != 0
        return false 
      else 
        return true
      end
    end

    def big_vm_resources(path)
      big_vms_resources = {}
      provider = elektron_placement.get(path)
      reserved = provider.body
      return reserved
    end

    def get_domain(domain_id)
      resp = elektron_resources.get("domains/#{domain_id}")
      return resp.body['domain'] || { 'services' => [] }
    end

    def get_project(domain_id, project_id)
      resp = elektron_resources.get("domains/#{domain_id}/projects/#{project_id}")
      return resp.body['project'] || { 'services' => [] }
    end

    def has_project_quotas?(domain_id, project_id)
      # look for any non-zero quota in a resource other than
      # "network/security_groups" or "network/security_group_rules" (those
      # start out non-zero because of the default security group)
      get_project(domain_id, project_id)['services'].any? do |srv|
        srv['resources'].any? do |res|
          has_quota = (res['quota'] || 0) > 0
          is_relevant = !/^security_group/.match?(res['name'] || '')
          has_quota && is_relevant
        end
      end
    end

  end
end
