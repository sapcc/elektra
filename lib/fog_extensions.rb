require 'fog/openstack/models/identity_v3/project'
require 'fog/openstack/models/identity_v3/domain'
require 'fog/openstack/models/compute/server'

class Fog::Identity::OpenStack::V3::Project

  attr_accessor :fid

  def fid
    p = ::Project.where(key: id).first
    return p.slug if p
    return id
  end

end

class Fog::Identity::OpenStack::V3::Domain

  attr_accessor :fid

  def fid
    p = ::Domain.where(key: id).first
    return p.slug if p
    return id
  end

end


class Fog::Compute::OpenStack::Server
  def power_state_string
    case os_ext_sts_power_state 
    when 1 then 'Running'
    when 3 then 'Paused'  
    when 4 then 'Shut Down'  
    else 
      'No State'
    end
  end
end