module BlockStorage
  module Driver
    class Interface < Core::ServiceLayer::Driver::Base

      def method_missing(m, *args, &block)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

    end
  end
end