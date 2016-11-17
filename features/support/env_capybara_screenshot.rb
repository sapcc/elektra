require 'capybara-screenshot'
require 'capybara-screenshot/cucumber'
require 'mime-types'

Capybara.save_and_open_page_path = "features/screenshots"

module Screenshots
  def self.upload(path) 
    basename     = File.basename(path)
    extension    = File.extname(path)[1..-1]
    type         = MIME::Types.type_for(extension)
    endpoint_url = URI.parse("#{endpoint}/debug/#{basename}")
    content      = File.read(path)

    Net::HTTP.start(endpoint_url.host, 
                    endpoint_url.port, 
                    use_ssl: endpoint_url.scheme == "https", 
                    verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      put = Net::HTTP::Put.new(endpoint_url.request_uri)
      put['X-Auth-Token']        = token
      put['X-Delete-After']      = 60 * 60 * 24 * 7
      put['Content-Disposition'] = "inline;filename=#{basename}"
      put['Content-Type']        = type
      http.request(put, content)
    end

    endpoint_url
  end

  def self.request_token
    endpoint_url = URI.parse(ENV.fetch('SCREEN_SHOT_UPLOAD_URL'))
    user         = ENV['SCREEN_SHOT_UPLOAD_USER'] 
    password     = ENV['SCREEN_SHOT_UPLOAD_PASSWORD'] 
    project      = ENV['SCREEN_SHOT_UPLOAD_PROJECT'] 
    domain       = ENV['SCREEN_SHOT_UPLOAD_DOMAIN']

    Net::HTTP.start(endpoint_url.host, 
                    endpoint_url.port, 
                    use_ssl: endpoint_url.scheme == "https", 
                    verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      post  = Net::HTTP::Post.new(endpoint_url.request_uri)
      post['Content-type'] = "application/json"
      post.body = { 
        "auth": {
          "identity": {
            "methods": [ 
              "password" 
            ],
            "password": {
              "user": {
                "name": user, 
                "password": password,
                "project": { 
                  "name": project
                }, 
                "domain": {
                  "name": domain 
                }
              }
            }
          }
        }
      }.to_json

      http.request(post)
    end
  end

  def self.endpoint
    @token ||= request_token
    JSON.parse(@token.body)["token"]["catalog"].find {|t| t["name"] == "swift"}["endpoints"].find{|t| t["interface"] == "public"}["url"]
  end

  def self.token
    @token ||= request_token
    @token["X-Subject-Token"] 
  end
end

at_exit do
  # do the work in a separate thread, to avoid stomping on $!,
  # since other libraries depend on it directly.
  Thread.new do
    unless Dir["features/screenshots/*"].empty?
      puts ""
      puts ""
      puts "         '"
      puts "    '    )" 
      puts "     ) ("
      puts "    ( .')  __/\\"
      puts "      (.  /o/\` \\"
      puts "       __/o/\`   \\"
      puts "FAIL  / /o/\`    /"
      puts "^^^^^^^^^^^^^^^^^^^^"
      puts ""
      puts "Some tests failed. But do not despair. Check these URLs:"

      Dir["features/screenshots/*"].each do |file|
        puts Screenshots::upload(File.expand_path(file))
      end

      puts ""
      puts ""
    end
  end.join unless Capybara.run_server
end
