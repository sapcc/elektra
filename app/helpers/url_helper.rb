module UrlHelper
  # prefixed to not interfere with ActionDispatch::Routing::UrlFor
  def sap_url_for(servicename)
    case servicename
    when 'documentation'
      # TODO: remove special treatment once prod is on the production cluster with the proper certificates
      return "http://#{servicename}.#{current_region}.cloud.sap:8080/"
    else
      return "https://#{servicename}.#{current_region}.cloud.sap/"
    end
  end
end
