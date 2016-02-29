module BlockStorage
  module Driver
    # Neutron calls
    class Interface < Core::ServiceLayer::Driver::Base
      ###################### NETWORKS #######################
      def test(filter={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end
    end
  end
end