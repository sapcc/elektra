# frozen_string_literal: true

# This class guarantees that the user is logged in and his token is rescoped.
# All subclasses which require a logged in user should inherit from this class.
class CachesController < ::ApplicationController

  def users
    name = params[:name] || params[:term] || ''

    # try to find user in object cache
    users = ObjectCache.where(cached_object_type: 'user').where(
      ['id ILIKE :name or name ILIKE :name', name: "%#{name}%"]
    ).to_a.uniq(&:name)

    data = if users.length.positive?
             users.map do |u|
               {
                 id: u.payload['description'], name: u.name, key: u.name,
                 uid: u.id, full_name: u.payload['description'],
                 email: u.payload['email']
               }
             end
           else
             # did not find anything in object cache -> try to find in UserProfile
             users = UserProfile.search_by_name(name).to_a.uniq(&:name)
             users.map do |u|
               {
                 id: u.full_name, name: u.name, key: u.name, uid: u.uid,
                 full_name: u.full_name, email: u.email
               }
             end
           end
    render json: data
  end

  def domains
    name = params[:name] || params[:term] || ''
    domains = FriendlyIdEntry.search('Domain', nil, name)
    render json: domains.collect { |d| { id: d.key, name: d.name } }.to_json
  end

  def projects
    name = params[:name] || params[:term] || ''

    projects = ObjectCache.where(cached_object_type: 'project').where(
      ['id ILIKE :name or name ILIKE :name', name: "%#{name}%"]
    ).to_a.uniq(&:name)

    projects ||= FriendlyIdEntry.search('Project', @scoped_domain_id, name)

    render json: (projects.collect do |project|
      { id: project.id || project.key, name: project.name }
    end.to_json)
  end
end
