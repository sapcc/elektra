class FriendlyIdEntry < ApplicationRecord
  validates :name, presence: true
  validates :key, presence: true
  extend FriendlyId

  friendly_id :name, use: :scoped, scope: :scope

  def self.search(class_name, scope, term)
    sql = [
      "class_name=? and (key ILIKE ? or name ILIKE ?) and endpoint=? #{"and lower(scope)=?" if scope}",
      class_name,
      "%#{term}%",
      "%#{term}%",
      Rails.configuration.keystone_endpoint,
    ]
    sql << scope.to_s.downcase if scope

    self.where(sql)
  end

  def self.find_by_class_scope_and_key_or_slug(class_name, scope, key_or_slug)
    sql = [
      "class_name=? and (lower(key)=? or lower(slug)=?) and endpoint=? #{"and lower(scope)=?" if scope}",
      class_name,
      key_or_slug.to_s.downcase,
      key_or_slug.to_s.downcase,
      Rails.configuration.keystone_endpoint,
    ]
    sql << scope.to_s.downcase if scope

    self.where(sql).first
  end

  def self.find_project(scope, key_or_slug)
    find_by_class_scope_and_key_or_slug("Project", scope, key_or_slug)
  end

  def self.find_domain(key_or_slug)
    find_by_class_scope_and_key_or_slug("Domain", nil, key_or_slug)
  end

  def self.find_or_create_entry(class_name, scope, key, name)
    sql = [
      "class_name=? #{"and lower(key)=?" if key} #{"and name=?" if name and !key} #{"and lower(scope)=?" if scope}",
      class_name,
    ]
    sql << key.to_s.downcase if key
    sql << name if name and !key
    sql << scope.to_s.downcase if scope

    entries = self.where(sql)

    if entries.length == 1 and
         entries.first.endpoint == Rails.application.config.keystone_endpoint
      return entries.first
    else
      entries.delete_all
      self.create(
        class_name: class_name,
        scope: scope,
        name: name,
        key: key,
        endpoint: Rails.application.config.keystone_endpoint,
      )
    end
  end

  def self.update_project_entry(project)
    if project.nil? || project.id.nil? ||
         !(project.id.is_a?(String) || project.id.is_a?(Integer))
      return nil
    end

    sql = [
      "class_name=? and lower(key)=? and lower(scope)=?",
      "Project",
      project.id,
      project.domain_id,
    ]

    entry = where(sql).first

    if entry && entry.name != project.name
      entry.name = project.attributes["name"]
      entry.slug = nil
      entry.save
    end
    entry
  end

  def self.delete_project_entry(project)
    if project.nil? || project.id.nil? ||
         !(project.id.is_a?(String) || project.id.is_a?(Integer))
      return nil
    end

    sql = [
      "class_name=? and lower(key)=? and lower(scope)=?",
      "Project",
      project.id,
      project.domain_id,
    ]

    entry = where(sql).first
    entry.delete if entry
  end
end
