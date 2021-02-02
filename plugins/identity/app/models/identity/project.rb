# frozen_string_literal: true

module Identity
  # This class represents the Openstack Project
  class Project < Core::ServiceLayer::Model
    validates :name, presence: { message: 'Name should not be empty' }
    validates :description, presence: { message: 'Please enter a description' }

    # limit from billing api and keystone
    validates :description,
              length: { maximum: 255, too_long: '255 characters is the maximum allowed' }

    attr_accessor :inquiry_id # to close inquiry after creation

    def after_save
      # FriendlyIdEntry.update_project_entry(self)
      FriendlyIdEntry.delete_project_entry(self)
      true
    end

    def sharding_enabled
      return read(:tags).include?('sharding_enabled') || false
    end

    def shards
      shards = []
      read(:tags).each do |tag|
        shards << tag if tag.start_with?('vc-')
      end
      shards
    end

    def subprojects_ids
      return @subprojetcs_ids if @subprojetcs_ids

      @subprojetcs_ids = read(:subtree)
      if @subprojetcs_ids.is_a?(Array)
        @subprojetcs_ids = @subprojetcs_ids.collect do |project_attrs|
          project_attrs.fetch('project', {}).fetch('id', nil)
        end
      end
      @subprojetcs_ids
    end

    def parents_project_ids
      return @parents_project_ids if @parents_project_ids

      @parents_project_ids = read(:parents)
      if @parents_project_ids.is_a?(Array)
        @parents_project_ids = @parents_project_ids.collect do |project_attrs|
          project_attrs.fetch('project', {}).fetch('id', nil)
        end
      elsif @parents_project_ids.is_a?(Hash)
        @parents_project_ids = hash_to_array(@parents_project_ids)
      end
      @parents_project_ids
    end

    def friendly_id
      return nil if id.nil?
      return id if domain_id.blank? || name.blank?

      friendly_id_entry = FriendlyIdEntry
                          .find_or_create_entry('Project', domain_id, id, attributes['name'])
      friendly_id_entry.slug
    end

    def hash_to_array(hash, array = [])
      hash.try(:each) do |k, v|
        array << k
        to_array(v, array)
      end
      array
    end
  end
end
