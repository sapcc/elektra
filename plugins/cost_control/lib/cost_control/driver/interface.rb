module CostControl
  module Driver
    class Interface < Core::ServiceLayer::Driver::Base

      ##### project masterdata

      def get_project_masterdata(project_id)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def update_project_masterdata(project_id, params={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      ##### domain masterdata

      def get_domain_masterdata(domain_id)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def update_domain_masterdata(domain_id, params={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

    end
  end
end
