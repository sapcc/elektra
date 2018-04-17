require 'elektron'

module ElektronMiddlewares
  class ObjectCache < Elektron::Middlewares::Base
    ID_KEYS = %w[id floating_ip]
    BLACKLIST_PARENT_KEYS = %w[version versions]

    def call(request_context)
      response = @next_middleware.call(request_context)
      debug = request_context.options[:debug]

      if debug
        Rails.logger.debug('\033[1;36m########### ObjectCache ##########')
      end

      if response.body
        begin
          objects = find_objects(response.body)
          ::ObjectCache.cache_objects(objects) if objects
        rescue
        end
      end

      Rails.logger.debug("########## End ##########\033[0m") if debug
      response
    end

    def find_objects(data, parent_key = nil)
      # ignore black listed keys.
      return nil if BLACKLIST_PARENT_KEYS.include?(parent_key)

      if data.is_a?(Hash)
        # only objects with key id are important.
        if data['id']
          # return nil if object contains only the id key.
          # There is no more data available!
          return nil if data.keys.length == 1
          # store the object type inside the object itself.
          data['cached_object_type'] = parent_key.singularize if parent_key
          return [data]
        end
        # objects does not contain the id attribute
        # -> search recursively for objects.
        objects = data.keys.each_with_object([]) do |key, array|
          object = find_objects(data[key], key)
          array << object if object
        end
        return objects.flatten

      elsif data.is_a?(Array)
        objects = data.each_with_object([]) do |hash, array|
          object = find_objects(hash, parent_key)
          array << object if object
        end
        return objects.flatten
      end
      nil
    end
  end
end
