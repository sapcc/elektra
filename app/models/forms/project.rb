require 'fog/openstack/models/identity_v3/project'

class Forms::Project < Forms::Base
  # available attributes: :id, :domain_id, :description, :enabled, :name, :links, :parent_id

  wrapper_for ::Fog::IdentityV3::OpenStack::Project

  ignore_attributes :parent_id, :links
  default_values enabled: true

  def after_save
    domain = ::Domain.friendly_find_or_create self.service.region, self.domain_id
    if domain
      p = ::Project.where(key: self.id).first
      p = ::Project.new unless p
      p.domain = domain
      p.key = self.id
      p.name = self.name
      p.save
    end
  end

  def before_destroy
    ::Project.find_by(key: self.id).destroy
  end

end
