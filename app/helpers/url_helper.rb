module UrlHelper
  # prefixed to not interfere with ActionDispatch::Routing::UrlFor
  def sap_url_for(servicename)
    return "https://#{servicename}.#{current_region}.#{request.domain}/"
  end

  def url_for_avatar
    return eval('"' + ENV['MONSOON_DASHBOARD_AVATAR_URL'] + '"') rescue "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(current_user.email ? current_user.email : '')}?d=mm&size=24x24"
  end
end
