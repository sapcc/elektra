class FriendlyIdEntry < ActiveRecord::Base
  validates :name, presence: true
  validates :key, presence: true
  extend FriendlyId

  friendly_id :name, :use => :scoped, :scope => :scope

  def self.find_by_class_scope_and_key_or_slug(class_name,scope,key_or_slug)
    sql = if scope
      [
        "class_name=? and scope=? and (key=? or slug=?) and endpoint=?",
        class_name,
        scope,
        key_or_slug,
        key_or_slug,
        Rails.application.config.keystone_endpoint
      ]
    else
      [ 
        "class_name=? and (key=? or slug=?) and endpoint=?",
        class_name, 
        key_or_slug,
        key_or_slug,
        Rails.application.config.keystone_endpoint
      ]
    end 
    self.where(sql).first
  end

  def self.find_or_create_entry(class_name,scope,key,name)
    if scope
      self.where(
        class_name: class_name, 
        scope: scope, 
        key: key, 
        endpoint: Rails.application.config.keystone_endpoint
      ).first_or_create(name: name)
    else  
      self.where(
        class_name: class_name, 
        key: key, 
        endpoint: Rails.application.config.keystone_endpoint
      ).first_or_create(name: name)
    end
  end

end