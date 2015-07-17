class Domain < ActiveRecord::Base

  has_many :projects, dependent: :destroy

  extend FriendlyId
  friendly_id :name, :use => :slugged


  def should_generate_new_friendly_id?
    name_changed?
  end

  def self.friendly_find_or_create region, fid
    begin
      # try with friendly id
      domain = Domain.friendly.find fid rescue ActiveRecord::RecordNotFound
      return domain if domain
      # try with key
      domain = Domain.where(key: fid).first
      return domain if domain
      # try to get from authority with key or unslugged name
      begin
        fog_domain = self.service_user(region).domains.find_by_id fid
      rescue
        fog_domain = self.service_user(region).domains.all(:name => fid).first
      end
      
      p ":::::::::::::::::::::"
      p fid
      p self.service_user(region).domains.all(:name => fid)

      if fog_domain
        domain = Domain.new
        domain.key = fog_domain.id
        domain.name = fog_domain.name
        domain.save
        return domain
      else
        raise ActiveRecord::RecordNotFound, "Domain #{fid} missing"
      end
    rescue => e
      p ">>>>>>>>>>>>>>>>>"
      puts e
      raise ActiveRecord::RecordNotFound, "Domain #{fid} missing"
    end
  end

  def self.service_user region
    @service_user ||= MonsoonOpenstackAuth.api_client(region).connection_driver.connection
  end

end
