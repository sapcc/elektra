module Networking
  module NetworksHelper
    def rbac_target(project)
      project == '*' ? 'All Projects' : "#{project} (#{services.identity.find_project(project).name})"
    end
  end
end
