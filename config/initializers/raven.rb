Raven.configure do |config|
  # httpclient is the only faraday adpater which handles no_proxy 
  config.http_adapter = :httpclient
  config.send_modules = false
end
