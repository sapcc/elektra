class Project < ActiveRecord::Base

  belongs_to :domain

  extend FriendlyId
  friendly_id :name, :use => :scoped, :scope => :domain

  def should_generate_new_friendly_id?
    name_changed?
  end
  
  def self.friendly_find_or_create region, domain, fid
    # try with friendly id
    project = domain.projects.friendly.find fid rescue ActiveRecord::RecordNotFound
    return project if project
    # try with key
    project = Project.where(key: fid, domain_id: domain.id).first
    return project if project
    # try to get from authority with key or unslugged name
    begin
      fog_project = service_user(region).projects.find_by_id fid
    rescue
      fog_project = service_user(region).projects.all(:name => fid).first
    end

    if fog_project
      project = Project.new
      project.key = fog_project.id
      project.name = fog_project.name
      project.domain = domain
      project.save
      return project
    else
      raise "Project missing"
    end
  end

  def self.service_user region
    @service_user ||= MonsoonOpenstackAuth.api_client(region).connection_driver.connection
  end

end
