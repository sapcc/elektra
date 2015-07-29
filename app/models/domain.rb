class Domain < ActiveRecord::Base

  has_many :projects, dependent: :destroy

  extend FriendlyId
  friendly_id :name, :use => :slugged

  def should_generate_new_friendly_id?
    name_changed?
  end
  
  def self.find_by_friendly_id_or_key(friendly_id_or_key)
    begin
      self.friendly.find(friendly_id_or_key)
    rescue
      self.where(key:friendly_id_or_key).first
    end  
  end
    
  def self.find_or_create_by_remote_domain(remote_domain)
    return nil unless remote_domain
    
    Domain.where(key:remote_domain.id).first_or_create do |domain|
      domain.key = remote_domain.id
      domain.name = remote_domain.name
    end
  end
end
