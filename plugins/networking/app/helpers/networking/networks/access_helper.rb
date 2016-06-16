module Networking
  module Networks::AccessHelper
    def rbac_target(project)
      project == '*' ? 'All Projects' : project_id_and_name(project)
    end
  end
end
