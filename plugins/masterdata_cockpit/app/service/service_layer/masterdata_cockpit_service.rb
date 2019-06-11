# frozen_string_literal: true

module ServiceLayer
  class MasterdataCockpitService < Core::ServiceLayer::Service
    def available?(_action_name_sym = nil)
      elektron.service?('sapcc-billing')
    end

    def elektron_billing
      @elektron_billing ||= elektron.service(
        'sapcc-billing', path_prefix: '/masterdata', interface: 'public'
      )
    end

    def project_map
      @project_map ||= class_map_proc(MasterdataCockpit::ProjectMasterdata)
    end

    def domain_map
      @domain_map ||= class_map_proc(MasterdataCockpit::DomainMasterdata)
    end

    def missing_projects
      elektron_billing.get('missing').map_to('body', &project_map)
    end

    def get_project(id)
      elektron_billing.get("projects/#{id}").map_to('body', &project_map)
    end

    def get_domain(id)
      elektron_billing.get("domains/#{id}").map_to('body', &domain_map)
    end

    def new_project_masterdata(attributes = {})
      project_map.call(attributes)
    end

    def new_domain_masterdata(attributes = {})
      domain_map.call(attributes)
    end

    def create_domain_masterdata(masterdata)
      id = masterdata['domain_id']
      elektron_billing.put("domains/#{id}") { masterdata }.body
    end

    def create_project_masterdata(masterdata)
      id = masterdata['project_id']
      elektron_billing.put("projects/#{id}") { masterdata }.body
    end

    def check_inheritance(domain_id, parent_id = '')
      elektron_billing.get(
        'inheritance', domain_id: domain_id, parent_id: parent_id
      ).map_to('body') do |data|
        MasterdataCockpit::ProjectInheritance.new(self, data)
      end
    end

    #
    # COSTING
    #
    def get_project_costing
      elektron_billing.get('projects', path_prefix: '/services/costing').body
    end

    def get_domain_costing
      elektron_billing.get('domains', path_prefix: '/services/costing').body
    end
  end
end
