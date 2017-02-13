class ProjectProfile < ActiveRecord::Base
  serialize :wizard_payload
  before_save :validate_wizard_payload

  INITIAL_WIZARD_PAYLOAD_SERVICES = [
    'cost_control',
    'networking',
    'block_storage',
    'resource_management'
  ]

  STATUS_SKIPED = 'skiped'
  STATUS_DONE = 'done'

  class UnregisteredWizardService < StandardError; end
  class BadStatus < StandardError; end

  def self.find_or_create_by_project_id(project_id)
    profile = self.where(project_id: project_id).first
    unless profile
      profile = self.create(project_id: project_id, wizard_payload: initial_wizard_payload)
    end
    profile
  end

  def wizard_status(service_name)
    wizard_payload[service_name.to_s]
  end

  def wizard_payload
    return @wizard_payload if @wizard_payload
    payload = read_attribute('wizard_payload') || {}
    @wizard_payload = INITIAL_WIZARD_PAYLOAD_SERVICES.inject({}){|hash,key| hash[key]=payload[key]; hash}
  end

  def wizard_finished?
    wizard_payload.values.select{|status| ![STATUS_DONE,STATUS_SKIPED].include?(status)}.length==0
  end

  def has_pending_wizard_services?
    wizard_payload.values.select{|status| status==STATUS_SKIPED}.length>0
  end

  def update_wizard_status(service_name,status)
    unless INITIAL_WIZARD_PAYLOAD_SERVICES.include?(service_name.to_s)
      raise UnregisteredWizardService.new("Service #{service_name} is not registered yet.")
    end
    unless [STATUS_DONE,STATUS_SKIPED,nil].include?(status)
      raise BadStatus.new("Valid values for status are nil,'done','skiped'.")
    end
    wizard_payload[service_name.to_s]=status
    save
  end

  private
  def validate_wizard_payload
    wizard_payload.delete_if{|key,value| !INITIAL_WIZARD_PAYLOAD_SERVICES.include?(key)}
  end

  def initial_wizard_payload
    INITIAL_WIZARD_PAYLOAD_SERVICES.inject({}){|hash,key| hash[key]=nil; hash}
  end
end
