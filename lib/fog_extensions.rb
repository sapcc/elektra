#require 'fog/openstack/models/identity_v3/projects'
require 'fog/openstack/models/identity_v3/project'
#require 'fog/openstack/models/identity_v3/domains'
require 'fog/openstack/models/identity_v3/domain'
require 'fog/openstack/models/compute/server'

class Fog::Identity::OpenStack::V3::Project

  def is_sandbox?
    self.name.end_with? "_sandbox"
  end
    
  def friendly_id
    project = ::Project.find_or_create_by_remote_project(self)
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
  def friendly_id
    domain = ::Domain.find_or_create_by_remote_domain(self)
    domain.nil? ? self.id : domain.slug
  end  
end   

class Fog::Compute::OpenStack::Server
  NO_STATE    = 0
  RUNNING     = 1
  BLOCKED     = 2
  PAUSED      = 3
  SHUT_DOWN   = 4
  SHUT_OFF    = 5
  CRASHED     = 6
  SUSPENDED   = 7
  FAILED      = 8
  BUILDING    = 9
  
  def power_state_string
    case os_ext_sts_power_state 
    when RUNNING then "Running"
    when BLOCKED then "Blocked"
    when PAUSED then "Paused"
    when SHUT_DOWN then "Shut down"
    when SHUT_OFF then "Shut off"
    when CRASHED then "Crashed"
    when SUSPENDED then "Suspended"
    when FAILED then "Failed"
    when BUILDING then "Building"
    else 
      'No State'
    end
  end
  
  def os_ext_sts_task_state
    task_state = attributes[:os_ext_sts_task_state]
    return nil if task_state.nil? or task_state.empty? or task_state.downcase=='none'
    return task_state
  end
end