# frozen_string_literal: true

module ServiceLayerNg
  module ObjectStorageServices
    module StorageObject
      # OBJECTS #

      OBJECTS_ATTRMAP = {
        # name in API response => name in our model (that is part of this class's interface)
        'bytes'         => 'size_bytes',
        'content_type'  => 'content_type',
        'hash'          => 'md5_hash',
        'last_modified' => 'last_modified_at',
        'name'          => 'path',
        'subdir'        => 'path', # for subdirectories, only this single attribute is given
      }
      OBJECT_ATTRMAP = {
        'content-length' => 'size_bytes',
        'content-type'   => 'content_type',
        'etag'           => 'md5_hash',
        'last-modified'  => 'last_modified_at',
        'x-timestamp'    => 'created_at',
        'x-delete-at'    => 'expires_at',
      }
      OBJECT_WRITE_ATTRMAP = {
        # name in our model => name in create/update API request
        'content_type'   => 'Content-Type',
        # 'expires_at'     => 'X-Delete-At', # this is special-cased in update_object()
      }

      def object_map
        @object_map ||= class_map_proc(ObjectStorage::Object)
      end


      def object_metadata(container_name,object_path)
        return nil if container_name.blank? or object_path.blank?
        response = elektron_object_storage.head("#{container_name}/#{object_path}")
        data = extract_object_header_data(response,container_name, object_path)
        object_map.call(data)
      end

      def object_content(container_name, object_path)
        body = elektron_object_storage.get("#{container_name}/#{object_path}").body
        # default behavior from misty -> converts returned json to an object
        # normaly thats fine but in some cases we want to download a json file from the object storage
        # if thats the case convert it back to json
        return body if body.is_a?(String)
        body.to_json
      end

      def list_objects(container_name, options={})
        # prevent prefix and delimiter with slash, if this happens an empty list is returned
        options[:prefix] = '' if options[:prefix] == '/' and options[:delimiter] == '/'

        list = elektron_object_storage.get(container_name).body
        list.map! do |o|
          object = map_attribute_names(o, OBJECTS_ATTRMAP)
          # path also serves as id() for Core::ServiceLayer::Model
          object['id'] = object['path']
          object['container_name'] = container_name
          if object.has_key?('last_modified_at')
            object['last_modified_at'] = DateTime.iso8601(object['last_modified_at']) # parse date
          end
          object
        end
      end

      def list_objects_at_path(container_name, object_path, filter={})
        object_path += '/' if !object_path.end_with?('/') && !object_path.empty?
        result = list_objects(
          container_name, filter.merge(prefix: object_path, delimiter: '/')
        )
        # if there is a pseudo-folder at `object_path`, it will be in the result, too;
        # filter this out since we only want stuff below `object_path`
        objects = result.reject { |obj| obj['id'] == object_path }
        objects.collect{ |data| object_map.call(data) }
      end

      def list_objects_below_path(container_name, object_path, filter={})
        byebug
        Rails.logger.debug  "[object-storage-service] -> list_objects_below_path -> #{container_name}, #{object_path}, #{filter}"
        path += '/' if !object_path.end_with?('/') && !object_path.empty?
        objects =  list_objects(container_name, filter.merge(prefix: object_path))
        map_to(ObjectStorage::Object, objects)
      end

      def copy_object(source_container_name, source_path, target_container_name, target_path, options={})
        byebug
        Rails.logger.debug  "[object-storage-service] -> copy_object -> #{source_container_name}/#{source_path} to #{target_container_name}/#{target_path}"
        Rails.logger.debug  "[object-storage-service] -> copy_object -> Options: #{options}"
        header_attrs = {
            'Destination' => "/#{target_container_name}/#{target_path}"
        }.merge(options)
        api.object_storage.copy_object(source_container_name,source_path,build_custom_request_header(header_attrs))
      end

      def move_object(source_container_name, source_path, target_container_name, target_path, options={})
        byebug
        Rails.logger.debug  "[object-storage-service] -> move_object -> #{source_container_name}/#{source_path} to #{target_container_name}/#{target_path}"
        Rails.logger.debug  "[object-storage-service] -> move_object -> Options: #{options}"
        copy_object(source_container_name, source_path, target_container_name, target_path, options.merge(with_metadata: true))
        delete_object(source_container_name, source_path)
      end

      def bulk_delete(targets)
        byebug
        Rails.logger.debug  "[object-storage-service] -> bulk_delete"
        Rails.logger.debug  "[object-storage-service] -> targets: #{targets}"

        capabilities = list_capabilities
        if capabilities.attributes.has_key?('bulk_delete')
          Rails.logger.debug  "[object-storage-service] -> bulk_delete -> running bulk-delete operation"
          # https://docs.openstack.org/swift/latest/middleware.html#bulk-delete
          # assemble the request object_list containing the paths to all targets
          object_list = ""
          targets.each do |target|
            unless target.has_key?(:container)
              raise ArgumentError, "malformed target #{target.inspect}"
            end
            object_list += target[:container]
            if target.has_key?(:object)
              object_list += "/" + target[:object]
            end
            object_list += "\n"
          end

          api.object_storage.bulk_delete(object_list)

        else
          Rails.logger.debug  "[object-storage-service] -> bulk_delete -> no bulk-delete capabilitie available, useing fallback"
          targets.each do |target|
            unless target.has_key?(:container)
              raise ArgumentError, "malformed target #{target.inspect}"
            end

            if target.has_key?(:object)
              delete_object(target[:container],target[:object])
            else
              delete_container(target[:container])
            end
          end
        end
      end

      def create_object(container_name, object_path, contents)
        byebug
        object_path = sanitize_path(object_path)
        Rails.logger.debug  "[object-storage-service] -> create_object -> #{container_name}, #{object_path}"

        # content type "application/directory" is needed on pseudo-dirs for
        # staticweb container listing to work correctly
        header_attrs = {}
        header_attrs['Content-Type'] = 'application/directory' if object_path.end_with?('/')
        header_attrs['Content-Type'] = ''
        # Note: `contents` is an IO object to allow for easy future expansion to
        # more clever upload strategies (e.g. SLO); for now, we just send
        # everything at once

        # stringify keys and values
        header_attrs.deep_merge!(header_attrs) { |_, _, v| v.to_s }
        header_attrs.stringify_keys!

        elektron_object_storage.put(
          "#{container_name}/#{object_path}",
          headers: header_attrs
        ) { contents.read }
        # api.object_storage.create_or_replace_object(container_name, object_path, contents.read, build_custom_request_header(header_attrs))
      end

      def delete_object(container_name,object_path)
        byebug
        Rails.logger.debug  "[object-storage-service] -> delete_object -> #{container_name}, #{object_path}"
        api.object_storage.delete_object(container_name,object_path)
        # return nil because nothing usable is returned from the api
        return nil
      end

      def update_object(object_path, params)
        container_name = params[:container_name]
        header_attrs = map_attribute_names(params, OBJECT_WRITE_ATTRMAP)

        unless params['expires_at'].nil?
          header_attrs['x-delete-at'] = params['expires_at'].getutc.strftime('%s')
        end

        (params['metadata'] || {}).each do |key, value|
          header_attrs["x-object-meta-#{key}"] = value
        end

        # stringify keys and values
        header_attrs.deep_merge!(header_attrs) { |_, _, v| v.to_s }
        header_attrs.stringify_keys!

        elektron_object_storage.post(
          "#{container_name}/#{object_path}", headers: header_attrs
        )
        # return nil because nothing usable is returned from the api
        nil
      end

      def create_folder(container_name, object_path)
        # a pseudo-folder is created by writing an empty object at its path, with
        # a "/" suffix to indicate the folder-ness
        elektron_object_storage.put(
          "#{container_name}/#{object_path}/",
          headers: { 'Content-Type' => 'application/directory' }
        )
      end

      def delete_folder(container_name, object_path)
        byebug
        Rails.logger.debug  "[object-storage-service] -> delete_folder -> #{container_name}, #{object_path}"
        targets = list_objects_below_path(container_name, sanitize_path(object_path) + '/').map do |obj|
          { container: container_name, object: obj.path }
        end
        bulk_delete(targets)
      end
    end
  end
end
