module Networking
  module RoutersHelper
    def foreign_router?(router)
      (router.tenant_id || router.project_id) != @scoped_project_id
    end
  end
end
