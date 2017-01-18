class ProjectProfile < ActiveRecord::Base
  def self.find_by_project(project)
    self.where(project_id: project.id).first
  end

  def update_wizard_status(service_name,status)
    wizard_payload ||= {}
    wizard_payload[service_name.to_s]=status.to_s
    save
  end
end
