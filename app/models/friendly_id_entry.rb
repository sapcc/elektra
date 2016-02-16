class FriendlyIdEntry < ActiveRecord::Base
  validates :name, presence: true
  validates :key, presence: true
  extend FriendlyId

  friendly_id :name, :use => :scoped, :scope => :scope

  def self.find_by_class_scope_and_key_or_slug(class_name,scope,key_or_slug)
    sql = [
      "class_name=? and (key=? or slug=?) and endpoint=? #{'and scope=?' if scope}", 
      class_name, 
      key_or_slug, 
      key_or_slug, 
      Rails.configuration.keystone_endpoint
    ]
    sql << scope if scope

    self.where(sql).first
  end

  def self.find_or_create_entry(class_name,scope,key,name)
    where_options = { class_name: class_name, key: key,  name: name }
    where_options[:scope] = scope if scope
    
    entries = self.where(where_options)

    if entries.length==1 and entries.first.endpoint==Rails.application.config.keystone_endpoint
      return entries.first
    else
      entries.delete_all
      self.create(class_name: class_name, scope: scope, name: name, key: key, endpoint: Rails.application.config.keystone_endpoint)
    end
  end

end