module CostControl
  module Driver
    class Interface < Core::ServiceLayer::Driver::Base

      ##### project metadata

      def get_project_metadata(project_id)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def update_project_metadata(project_id, params={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

    end
  end
end
