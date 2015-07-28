#require 'fog/openstack/models/identity_v3/projects'
require 'fog/openstack/models/identity_v3/project'
#require 'fog/openstack/models/identity_v3/domains'
require 'fog/openstack/models/identity_v3/domain'
require 'fog/openstack/models/compute/server'

class Fog::Identity::OpenStack::V3::Project

  attr_accessor :fid

  def fid
    p = ::Project.where(key: id).first
    return p.slug if p
    return id
  end

  def is_sandbox?
    self.name.end_with? "_sandbox"
  end
  
  def domain
    service.domains.find_by_id(domain_id)
  end
  
  def friendly_id
    project = Project.find_or_create_by_remote_project(self)
    project.nil? ? self.id : project.slug
  end
end


# class Fog::Identity::OpenStack::V3::Domains
#   alias_method :orig_find_by_id, :find_by_id
#
#   def find_by_id(id)
#     local_domain = begin
#       Domain.friendly.find(id)
#     rescue
#       Domain.where(key:id).first
#     end
#
#     id = local_domain.key if local_domain
#     remote_domain = orig_find_by_id(id)
#
#     if remote_domain
#       Domain.find_or_create_by_remote_domain(remote_domain)
#     end
#     remote_domain
#   end
# end
#
# class Fog::Identity::OpenStack::V3::Projects
#   alias_method :orig_find_by_id, :find_by_id
#
#   def find_by_id(domain_id,project_id,options={})
#     if Project.where(key:project_id).first
#       return orig_find_by_id(project_id)
#     end
#
#     local_domain = begin
#       Domain.friendly.find(domain_id)
#     rescue
#       d = Domain.where(key:domain_id).first
#       unless d
#         remote_domain = begin
#           service.domains.find_by_id(domain_id)
#         rescue
#           service.domains.all(name: domain_id).first
#         end
#         d = Domain.find_or_create_by_remote_domain(remote_domain)
#       end
#       d
#     end
#
#     local_project = begin
#       local_domain.projects.friendly.find(project_id)
#     rescue
#       local_domain.projects.where(key:project_id).first
#     end
#
#     project_id = local_project.key if local_project
#     remote_project = orig_find_by_id(project_id,options)
#
#     if remote_project
#       Project.find_or_create_by_remote_project(remote_project)
#     end
#     remote_project
#   end
# end

class Fog::Identity::OpenStack::V3::Domain

  attr_accessor :fid

  def fid
    p = ::Domain.where(key: id).first
    return p.slug if p
    return id
  end
    
  
  def friendly_id
    domain = Domain.find_or_create_by_remote_domain(self)
    domain.nil? ? self.id : domain.slug
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