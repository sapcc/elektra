module ServiceLayerNg

  class MasterdataService < Core::ServiceLayerNg::Service

    def available?(_action_name_sym = nil)
      puts "#################"
      api.catalog_include_service?('sapcc-analytics', region)
    end

  end
end
