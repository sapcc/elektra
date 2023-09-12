module Networking
  module Networks::AccessHelper
    def rbac_target(project)
      if project == "*"
        "All Projects"
      else
        project_id_and_name(project)
      end
    end
  end
end
