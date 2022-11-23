module ServiceLayer
    class NebulaService < Core::ServiceLayer::Service
      def available?(_action_name_sym = nil)
        elektron.service?('nebula')
      end
    end
  end