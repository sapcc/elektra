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
    if project.nil?
      domain = Domain.find_by_friendly_id_or_key(remote_project.domain_id)
      return nil unless domain
      project ||= Project.new
      project.key = remote_project.id
      project.name = remote_project.name
      project.domain = domain
      project.save
    end
    project
  end
end
