# frozen_string_literal: true

module ServiceLayer
  # implements images api
  class ImageService < Core::ServiceLayer::Service
    include ImageServices::Image
    include ImageServices::Member

    def available?(_action_name_sym = nil)
      elektron.service?('image')
    end

    def elektron_images
      @elektron_images ||= elektron.service(
        'image', path_prefix: '/v2'
      )
    end
  end
end
