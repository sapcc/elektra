class ProjectProfile < ActiveRecord::Base
  serialize :wizard_payload
  before_save :write_wizard_status

  STATUS_DONE = 'done'
  STATUS_SKIPPED = 'skipped'
  STATUS_PENDING = 'pending'

  def self.find_project_id(project_id)
    self.where(project_id: project_id).first
  end

  def self.find_or_create_by_project_id(project_id)
    profile = self.where(project_id: project_id).first
    unless profile
      profile = self.create(project_id: project_id, wizard_payload: {})
    end
    profile
  end

  def wizard_payload
    return @wizard_payload if @wizard_payload
    @wizard_payload = read_attribute('wizard_payload') || {}
  end

  def wizard_status(key)
    wizard_payload[key]["status"] if wizard_payload[key]
  end

  def wizard_data(key)
    hash = wizard_payload[key]
    if hash and hash["data"]
      return hash["data"].with_indifferent_access
    end
  end

  def wizard_finished?(*service_names)
    status = true
    service_names.each do |service_name|
      status &= (wizard_payload[service_name] and
      wizard_payload[service_name]["status"]==STATUS_DONE)
    end
    status
  end

  def update_wizard_status(service_name, status, data=nil)
    wizard_payload[service_name] ||= {}
    wizard_payload[service_name]["status"] = status
    wizard_payload[service_name]["data"] = data
    update_attribute(:wizard_payload,wizard_payload)
  end

  private
  def write_wizard_status
    write_attribute('wizard_payload',wizard_payload)
  end
end
