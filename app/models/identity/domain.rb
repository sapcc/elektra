module Identity
  class Domain < OpenstackServiceProvider::BaseObject
    def friendly_id
      domain = ::Domain.find_or_create_by_remote_domain(self)
      domain.nil? ? self.id : domain.slug
    end  
  end
end