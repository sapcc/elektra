module UrlHelper
  # prefixed to not interfere with ActionDispatch::Routing::UrlFor
  def sap_url_for(servicename)
    # special handling for global services
    region = servicename == "documentation" ? "global" : "#{current_region}"

    return "https://#{servicename}.#{region}.#{request.domain}/"
  end

  def url_for_avatar(size=24)
    avatar_url=""
    begin
      avatar_url = eval('"' + ENV["MONSOON_DASHBOARD_AVATAR_URL"] + '"').gsub(/size=24x24/, "s=#{size.to_s}x#{size.to_s}")
    rescue StandardError
      avatar_url="https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(current_user.email ? current_user.email : "")}?d=mm&s=#{size.to_s}"
    end
    
    # check the URL before returning it to prevent broken images
    # this will not prevent broken images if the URL is from the client not accessible
    begin
      uri = URI.parse(avatar_url)
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        return avatar_url
      else
        raise StandardError # Raise an error to fall back to default image
      end
    rescue StandardError
      avatar_url="/images/avatar-default.png"
    end
    return avatar_url
  end
end

#uri = URI.parse(avatar_url)
#response = Net::HTTP.get_response(uri)
#if response.is_a?(Net::HTTPSuccess)
#  return avatar_url
#else
#  raise StandardError # Raise an error to fall back to default image
#end
#rescue StandardError
#  # Fallback to default image if there's an error or URL is not accessible
#  return "/images/avatar-default.png"
#end