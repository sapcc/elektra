# frozen_string_literal: true

module ServiceLayer
  module ObjectStorageServices
    # implements Openstack Swift Container API
    module Container
      # CONTAINER #

      CONTAINERS_ATTRMAP = {
        # name in API response => name in our model (that is part of this class's interface)
        'bytes' => 'bytes_used',
        'count' => 'object_count',
        'name'  => 'name'
      }.freeze

      CONTAINER_ATTRMAP = {
        # name in API => name in our model
        'x-container-object-count'      => 'object_count',
        'x-container-bytes-used'        => 'bytes_used',
        'x-container-meta-quota-bytes'  => 'bytes_quota',
        'x-container-meta-quota-count'  => 'object_count_quota',
        'x-container-read'              => 'read_acl',
        'x-container-write'             => 'write_acl',
        'x-versions-location'           => 'versions_location',
        'x-container-meta-web-index'    => 'web_index',
        'x-container-meta-web-listings' => 'web_file_listing'
      }.freeze

      CONTAINER_WRITE_ATTRMAP = {
        # name in our model => name in create/update API request
        'bytes_quota'        => 'x-container-meta-quota-bytes',
        'object_count_quota' => 'x-container-meta-quota-count',
        'read_acl'           => 'x-container-read',
        'write_acl'          => 'x-container-write',
        'versions_location'  => 'x-versions-location',
        'web_index'          => 'x-container-meta-web-index',
        'web_file_listing'   => 'x-container-meta-web-listings'
      }.freeze

      def container_map
        @container_map ||= class_map_proc(ObjectStorage::Container)
      end

      def containers
        list = elektron_object_storage.get('/').body
        list.map do |c|
          container_map.call(map_attribute_names(c, CONTAINERS_ATTRMAP))
        end
      end

      def container_details_and_list_objects(container_name)
        elektron_object_storage.get(container_name).map_to(
          'body', &container_map
        )
      end

      def container_metadata(container_name)
        response = elektron_object_storage.head(container_name)
        data = extract_container_header_data(response, container_name)
        container_map.call(data)
      end

      def new_container(attributes = {})
        container_map.call(attributes)
      end

      def empty(container_name)
        targets = list_objects(container_name).map do |obj|
          { container: container_name, object: obj['path'] }
        end
        bulk_delete(targets)
      end

      def empty?(container_name)
        list_objects(container_name, limit: 1).count.zero?
      end

      def create_container(params = {})
        name = params.delete(:name)
        elektron_object_storage.put(name) { params }
        # return nil because nothing usable is returned from the API
        nil
      end

      def delete_container(container_name)
        elektron_object_storage.delete(container_name)
        # return nil because nothing usable is returned from the API
        nil
      end

      def update_container(container_name, params = {})
        # update container properties and access control

        # remove web-listing meta so it is completly disabled
        # if "x-container-meta-web-listings" is only set to false web-listing is
        # not completly disabled. That means the web access returns a html site
        # that informs you that web-listing was disabled.
        # If (in that case) public read access is allowed it is not possible to get a listing in
        # json or xml format because the middleware will return the html site that 
        # web-listing was disabled.
        header_attrs = map_attribute_names(params, CONTAINER_WRITE_ATTRMAP)
        unless header_attrs["x-container-meta-web-listings"]
          header_attrs["x-remove-container-meta-web-listings"] = '1'
          header_attrs.delete("x-container-meta-web-listings")
        end

        # convert difference between old and new metadata into a set of changes
        old_metadata = params['original_metadata']
        new_metadata = params['metadata']
        if old_metadata.nil? && !new_metadata.nil?
          raise InputError, 'cannot update metadata without knowing the current metadata'
        end
        (old_metadata || {}).each do |key, _value|
          unless new_metadata.key?(key)
            header_attrs["x-remove-container-meta-#{key}"] = '1'
          end
        end
        (new_metadata || {}).each do |key, value|
          if old_metadata[key] != value
            header_attrs["x-container-meta-#{key}"] = value
          end
        end

        # update metadata
        # stringify keys and values
        header_attrs = stringify_header_values(header_attrs)

        elektron_object_storage.post(container_name, headers: header_attrs)
        # return nil because nothing usable is returned from the API
        nil
      end

      protected

      def extract_container_header_data(response, container_name = nil)
        header_hash = map_attribute_names(extract_header_data(response), CONTAINER_ATTRMAP)
        # enrich data with additional information
        header_hash['id']               = header_hash['name'] = container_name
        header_hash['public_url']       = public_url(container_name)
        header_hash['web_file_listing'] = header_hash['web_file_listing'] == 'true' # convert to Boolean
        header_hash['metadata']         = extract_metadata_data(extract_header_data(response), 'x-container-meta-').reject do |key, _value|
          # skip metadata fields that are recognized by us
          CONTAINER_ATTRMAP.key?('x-container-meta-' + key)
        end

        header_hash
      end
    end
  end
end
