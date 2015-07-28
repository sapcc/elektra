require 'fog/openstack/models/identity_v3/project'

class Forms::Project < Forms::Base
  # available attributes: :id, :domain_id, :description, :enabled, :name, :links, :parent_id

  wrapper_for ::Fog::IdentityV3::OpenStack::Project

  ignore_attributes :parent_id, :links
  default_values enabled: true

  def after_save
    Project.find_or_create_by_remote_project(self)
  end

  def before_destroy
    ::Project.find_by(key: self.id).destroy
  end

end