module ServiceLayerNg

  class MasterdataCockpitService < Core::ServiceLayerNg::Service

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('sapcc-analytics', region)
    end

  end
end
