require "restclient"

# RestClient logs using << which isn't supported by the Rails logger,
# so wrap it up with a little proxy object.
# downgraded to debug level in production because of sensitive data (tokens)
RestClient.log =
  Object.new.tap do |proxy|
    def proxy.<<(message)
      if Rails.env == "development"
        Rails.logger.info message
      else
        Rails.logger.debug message
      end
    end
  end
