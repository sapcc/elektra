module Image
  class Image < Core::ServiceLayerNg::Model
    def publish
      rescue_api_errors do
        self.attributes = service.publish_image(id)
      end
    end

    def unpublish
      rescue_api_errors do
        self.attributes = service.unpublish_image(id)
      end
    end
  end
end
