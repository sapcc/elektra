module Networking
  module Networks::AccessHelper
    def rbac_target(project)
      if project == "*"
        haml_concat "All Projects"
      else
        project_id_and_name(project)
      end
    end
  end
end
