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
  
  # def self.friendly_find_or_create admin_identity_service, fid
  #   begin
  #     # try with friendly id
  #     domain = Domain.friendly.find fid rescue ActiveRecord::RecordNotFound
  #     return domain if domain
  #     # try with key
  #     domain = Domain.where(key: fid).first
  #     return domain if domain
  #     # try to get from authority with key or unslugged name
  #     begin
  #       fog_domain = admin_identity_service.domains.find_by_id fid
  #
  #       p "::::::::::::::"
  #       p (admin_identity_service.domains.find_by_id fid)
  #     rescue
  #       p '.......................'
  #       p admin_identity_service.domains.all(:name => fid).first
  #       fog_domain = admin_identity_service.domains.all(:name => fid).first
  #     end
  #
  #     if fog_domain
  #       domain = Domain.new
  #       domain.key = fog_domain.id
  #       domain.name = fog_domain.name
  #       domain.save
  #       return domain
  #     else
  #       raise ActiveRecord::RecordNotFound, "Domain #{fid} missing"
  #     end
  #   rescue
  #     raise ActiveRecord::RecordNotFound, "Domain #{fid} missing"
  #   end
  # end
  
  #
  # def self.friendly_find_or_create region, fid
  #   begin
  #     # try with friendly id
  #     domain = Domain.friendly.find fid rescue ActiveRecord::RecordNotFound
  #     return domain if domain
  #     # try with key
  #     domain = Domain.where(key: fid).first
  #     return domain if domain
  #     # try to get from authority with key or unslugged name
  #     begin
  #       fog_domain = self.service_user(region).domains.find_by_id fid
  #
  #       # p "::::::::::::::"
  #       # p (self.service_user(region).domains.find_by_id fid)
  #     rescue
  #       # p '.......................'
  #       # p self.service_user(region).domains.all(:name => fid).first
  #       fog_domain = self.service_user(region).domains.all(:name => fid).first
  #     end
  #
  #     if fog_domain
  #       domain = Domain.new
  #       domain.key = fog_domain.id
  #       domain.name = fog_domain.name
  #       domain.save
  #       return domain
  #     else
  #       raise ActiveRecord::RecordNotFound, "Domain #{fid} missing"
  #     end
  #   rescue
  #     raise ActiveRecord::RecordNotFound, "Domain #{fid} missing"
  #   end
  # end
  #
  # def self.service_user region
  #   # p ">>>>>>>>>>>>>>>>>>>>>"
  #   # p "region: #{region}"
  #   # p MonsoonOpenstackAuth.api_client(region).connection_driver.connection
  #
  #
  #   @service_user ||= MonsoonOpenstackAuth.api_client(region).connection_driver.connection
  # end

end
