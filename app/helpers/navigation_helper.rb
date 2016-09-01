module NavigationHelper
  def navigation_context(domain, project)
    if domain != 'ccadmin'
      :services
    elsif project == 'cloud_admin'
      :cloud_admin
    elsif project == 'dns_master'
      :dns
    elsif project == 'os-image-build'
      :image
    elsif project == 'master'
      :master
    else
      :services
    end
  end
end
