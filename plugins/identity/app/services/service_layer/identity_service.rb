# frozen_string_literal: true

module ServiceLayer
  # This class implements the identity api
  class IdentityService < Core::ServiceLayer::Service
    include IdentityServices::User
    include IdentityServices::Project
    include IdentityServices::Domain
    include IdentityServices::Group
    include IdentityServices::Role
    include IdentityServices::RoleAssignment
    include IdentityServices::Tag
    include IdentityServices::Ec2Credential

    def available?(_action_name_sym = nil)
      elektron.service?("identity")
    end

    def elektron_identity
      @elektron_identity ||= elektron.service("identity", path_prefix: "/v3")
    end

    def find_domain_and_project(filter)
      domain =
        if filter[:domain]
          domains(name: filter[:domain]).first || find_domain(filter[:domain])
        end

      return unless filter[:project]

      project =
        if domain
          projects(domain_id: domain.id, name: filter[:project]).first
        end || find_project(filter[:project])

      if project && !domain ||
           domain && project && domain.id != project.domain_id
        domain = find_domain(project.domain_id)
      end
      [domain, project]
    end
  end
end
