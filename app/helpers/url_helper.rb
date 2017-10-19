module UrlHelper
  # prefixed to not interfere with ActionDispatch::Routing::UrlFor
  def sap_url_for(servicename)
    # special handling for global services
    region = servicename == 'documentation' ? 'global' : "#{current_region}"
    
    return "https://#{servicename}.#{region}.#{request.domain}/"
  end

  def url_for_avatar
    return eval('"' + ENV['MONSOON_DASHBOARD_AVATAR_URL'] + '"') rescue "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(current_user.email ? current_user.email : '')}?d=mm&size=24x24"
  end

  def url_for_cam(domainname)
    if ENV['MONSOON_DASHBOARD_CAM_URL']
      ENV['MONSOON_DASHBOARD_CAM_URL'] + "?item=request&profile=CC%20#{domainname.upcase}%20Openstack%20Domain%20Access"
    else
      "https://spc40-emea.byd.sap.corp/sap/bc/webdynpro/a1sspc/cam_wd_central?item=request&profile=CC%20#{domainname.upcase}%20Openstack%20Domain%20Access"
    end
  end
end
