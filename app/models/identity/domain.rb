module Identity
  class Domain < OpenstackServiceProvider::BaseObject
    
    # def friendly_id
    #   return nil if id.nil?
    #   return id if name.blank?
    #
    #   friendly_id_entry = FriendlyIdCache.find_or_create_entry(self.class.name,nil,id,name)
    #   friendly_id_entry.slug
    # end
    #
    # def self.find_by_friendly_id_or_key(@driver,friendly_id_or_key)
    #   friendly_id_entry = FriendlyIdCache.where(class_name: self.class.name).friendly.find(friendly_id_or_key)
    # end
    
    def friendly_id
      domain = ::Domain.find_or_create_by_remote_domain(self)
      domain.nil? ? self.id : domain.slug
    end  
  end
end