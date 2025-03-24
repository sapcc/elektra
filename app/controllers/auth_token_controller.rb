require 'net/http'
require 'uri'

class AuthTokenController < ActionController::Base
  layout 'plain'
  skip_before_action :verify_authenticity_token, only: [:verify]

  def verify
    token = params[:token]

    keystone_endpoint = ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT']
    # remove /v3 from the endpoint if it exists
    keystone_endpoint = keystone_endpoint.gsub('/v3', '') if keystone_endpoint.include?('/v3')

    # Define the URL you want to make a GET request to
    url = URI.parse("#{keystone_endpoint}/v3/auth/tokens")

    # Create a new HTTP request object
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true if url.scheme == 'https' # Use SSL if it is HTTPS

    # Create a new GET request
    request = Net::HTTP::Get.new(url)

    # Set the custom headers
    request['X-Subject-Token'] = token
    request['X-Auth-Token'] = token
    # Send the request
    response = http.request(request)

    domain_id = JSON.parse(response.body)['token']['user']['domain']['id']

    # redirect to the auth gem to create the session for the given domain_id
    redirect_to "/#{domain_id}/auth/consume-auth-token?domain_id=#{domain_id}&token=#{token}&after_login=/#{domain_id}/home"
  rescue StandardError
    render action: :verify
  end
end
