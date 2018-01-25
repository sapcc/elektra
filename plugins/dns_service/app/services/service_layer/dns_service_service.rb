# frozen_string_literal: true

module ServiceLayer
  class DnsServiceService < Core::ServiceLayer::Service
    # middleware for elektron to setup headers based on params
    class SetupHeadersMiddleware
      def call(params, options, data)
        # user needs to have admin privileges to ask for all projects
        all_projects = params.delete(:all_projects)

        # user needs to have admin privileges to impersonate another project
        # don't ask for all and one project at the same time
        project_id = params.delete(:project_id) unless all_projects

        options[:headers] ||= {}
        if project_id
          options[:headers]['X-Auth-Sudo-Project-Id'] = project_id
        elsif all_projects
          options[:headers]['X-Auth-All-Projects'] = all_projects.to_s
        end
        [params, options, data]
      end
    end

    include DnsServiceServices::Zone
    include DnsServiceServices::Pool
    include DnsServiceServices::Recordset
    include DnsServiceServices::ZoneTransfer

    def available?(_action_name_sym = nil)
      elektron.service?('dns')
    end

    def elektron_dns
      @elektron_dns ||= create_elektron_service
    end

    private

    def create_elektron_service
      dns = elektron.service('dns', path_prefix: '/v2')
      dns.add_middleware(SetupHeadersMiddleware)
      dns
    end
  end
end
