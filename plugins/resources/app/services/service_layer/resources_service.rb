# frozen_string_literal: true

module ServiceLayer
  class ResourcesService < Core::ServiceLayer::Service

    def available?(_action_name_sym = nil)
      elektron.service?('resources')
    end

    def elektron_resources
      @elektron_resources ||= elektron.service(
        'resources', path_prefix: '/v1'
      )
    end

    def get_domain(domain_id)
      resp = elektron_resources.get("domains/#{domain_id}")
      return resp.body['domain'] || { services: [] }
    end

    def get_project(domain_id, project_id)
      resp = elektron_resources.get("domains/#{domain_id}/projects/#{project_id}")
      return resp.body['project'] || { services: [] }
    end

  end
end
