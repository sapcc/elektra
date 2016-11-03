module UrlHelper
  # prefixed to not interfere with ActionDispatch::Routing::UrlFor
  def sap_url_for(servicename)
    return "https://#{servicename}.#{current_region}.#{request.domain}/"
  end

  def url_for_avatar
    return eval('"' + ENV['MONSOON_DASHBOARD_AVATAR'] + '"')
  end
end
