module UrlHelper
  # prefixed to not interfere with ActionDispatch::Routing::UrlFor
  def sap_url_for(servicename)
    case servicename
    when 'documentation'
      # TODO: remove special treatment once prod is on the production cluster with the proper certificates
      return "http://#{servicename}.#{ENV['MONSOON_DASHBOARD_REGION']}.cloud.sap:8080/"
    else
      return "https://#{servicename}.#{ENV['MONSOON_DASHBOARD_REGION']}.cloud.sap/"
    end
  end
end
