module ObjectStorage
  class EntryController < ApplicationController

    authorization_required

    def index
      # if the user is allowed to list containers, continue to the actual UI
      if current_user.is_allowed?('object_storage:container_list')
        redirect_to plugin('object_storage').containers_path
        return
      end

      # special case for monsoon2 legacy: explain how to enable Swift for legacy projects
      if services.identity.find_domain(@scoped_domain_id).name == 'monsoon2'
        render action: 'howtoenable_monsoon2'
      else
        render action: 'howtoenable'
      end
    end

    def capabilities
      @capabilities = sort_keys(services.object_storage.capabilities)
    end

    private

    def sort_keys(value)
      # The only way to print a YAML or JSON representation of a hash with
      # sorted keys is to sort the hash. This is clearly insane because hashes
      # are, by nature, unsorted, yet it works. WTF.
      if value.is_a?(Hash)
        result = {}
        value.keys.sort.each { |k| result[k] = sort_keys(value[k]) }
        return result
      elsif value.is_a?(Array)
        # call sort_keys() recursively!
        return value.map { |v| sort_keys(v) }
      else
        return value
      end
    end

  end
end
