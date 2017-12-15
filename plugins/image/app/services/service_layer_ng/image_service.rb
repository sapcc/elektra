# frozen_string_literal: true

module ServiceLayerNg
  # implements images api
  class ImageService < Core::ServiceLayerNg::Service
    include ImageServices::Image
    include ImageServices::Member

    def available?(_action_name_sym = nil)
      elektron.service?('image')
    end

    def elektron_images
      @elektron_images ||= elektron(debug: Rails.env.development?).service(
        'image', path_prefix: '/v2'
      )
    end
  end
end
