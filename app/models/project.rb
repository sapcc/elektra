class Project < ActiveRecord::Base

  belongs_to :domain

  extend FriendlyId
  friendly_id :name, :use => :scoped, :scope => :domain

  def should_generate_new_friendly_id?
    name_changed?
  end

  def self.find_by_domain_fid_and_fid(domain_fid,project_fid)
    project = self.where(key:project_fid).first
    unless project
      domain = Domain.find_by_friendly_id_or_key(domain_fid)
      if domain
        project = domain.projects.friendly.find(project_fid) rescue nil
      end
    end
    project
  end
  
  def self.find_or_create_by_remote_project(remote_project)
    return nil unless remote_project
    
    project = Project.where(key:remote_project.id).first
    if project.nil? or project.domain.nil?
      domain = Domain.find_or_create_by_remote_domain(remote_project.domain)
      return nil unless domain
      project ||= Project.new
      project.key = remote_project.id
      project.name = remote_project.name
      project.domain = domain
      project.save
    end
    project
  end

  # def self.friendly_find_or_create admin_identity_service, domain, fid
  #   # try with friendly id
  #   project = domain.projects.friendly.find fid rescue ActiveRecord::RecordNotFound
  #   return project if project
  #   # try with key
  #   project = Project.where(key: fid, domain_id: domain.id).first
  #   return project if project
  #   # try to get from authority with key or unslugged name
  #   begin
  #     fog_project = admin_identity_service.projects.find_by_id fid
  #   rescue
  #     fog_project = admin_identity_service.projects.all(:name => fid).first
  #   end
  #
  #   if fog_project
  #     project = Project.new
  #     project.key = fog_project.id
  #     project.name = fog_project.name
  #     project.domain = domain
  #     project.save
  #     return project
  #   else
  #     raise "Project missing"
  #   end
  # end
    
  # def self.friendly_find_or_create region, domain, fid
  #   # try with friendly id
  #   project = domain.projects.friendly.find fid rescue ActiveRecord::RecordNotFound
  #   return project if project
  #   # try with key
  #   project = Project.where(key: fid, domain_id: domain.id).first
  #   return project if project
  #   # try to get from authority with key or unslugged name
  #   begin
  #     fog_project = service_user(region).projects.find_by_id fid
  #   rescue
  #     fog_project = service_user(region).projects.all(:name => fid).first
  #   end
  #
  #   if fog_project
  #     project = Project.new
  #     project.key = fog_project.id
  #     project.name = fog_project.name
  #     project.domain = domain
  #     project.save
  #     return project
  #   else
  #     raise "Project missing"
  #   end
  # end
  #
  # def self.service_user region
  #   @service_user ||= MonsoonOpenstackAuth.api_client(region).connection_driver.connection
  # end

end
