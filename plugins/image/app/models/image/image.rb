module Image
  class Image < Core::ServiceLayer::Model
    VISIBILITY_VALUES = %w[public private shared community]

    def update_visibility(new_visibility)
      unless VISIBILITY_VALUES.include?(new_visibility)
        errors.add(
          :visibility,
          'Wrong value for visibility. Allowed values are: ' \
          "#{VISIBILITY_VALUES.join(', ')}"
        )
      end

      rescue_api_errors do
        self.attributes = service.set_image_visibility(id, new_visibility)
      end
      errors.empty?
    end
  end
end
