require 'fog/openstack/models/identity_v3/project'
require 'fog/openstack/models/identity_v3/domain'

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
