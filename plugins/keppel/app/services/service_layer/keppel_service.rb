module ServiceLayer
  class KeppelService < Core::ServiceLayer::Service
    def available?(_action_name_sym = nil)
      elektron.service?("keppel")
    end
  end
end
