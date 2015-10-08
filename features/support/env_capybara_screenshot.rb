require 'capybara-screenshot'
require 'capybara-screenshot/cucumber'

Capybara.save_and_open_page_path = "features/screenshots"

module Screenshots
  def self.upload(path) 
    basename     = File.basename(path)
    extension    = File.extname(path)[1..-1]
    type         = Mime::Type.lookup_by_extension(extension)
    endpoint_url = URI.parse("https://localhost/v1/AUTH_p-7496766f1/debug/#{basename}")
    content      = File.read(path)

    Net::HTTP.start(endpoint_url.host, endpoint_url.port) do |http|
      put = Net::HTTP::Put.new(endpoint_url.request_uri)
      put['X-Auth-Token']        = token
      put['X-Delete-After']      = 60 * 60 * 24 * 7
      put['Content-Disposition'] = "inline;filename=#{basename}"
      put['Content-Type']        = type
      http.request(put, content)
    end

    endpoint_url
  end

  def self.token
    fog = Fog::Identity::OpenStack::V3.new(
      openstack_domain_name:  "monsooncc",
      openstack_project_name: "p-7496766f1",
      openstack_api_key:      "secret",
      openstack_userid:       "concourse",
      openstack_auth_url:     "https://localhost:5000/v3/auth/tokens",
      openstack_region:       "europe"
    ).credentials[:openstack_auth_token]
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
  end.join
end
