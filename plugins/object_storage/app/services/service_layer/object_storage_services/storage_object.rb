# frozen_string_literal: true

module ServiceLayer
  module ObjectStorageServices
    # implements Openstack SWIFT API
    module StorageObject
      # OBJECTS #

      OBJECTS_ATTRMAP = {
        # name in API response => name in our model (that is part of this class's interface)
        "bytes" => "size_bytes",
        "content_type" => "content_type",
        "hash" => "md5_hash",
        "last_modified" => "last_modified_at",
        "name" => "path",
        "subdir" => "path", # for subdirectories, only this single attribute is given
      }

      OBJECT_ATTRMAP = {
        "content-length" => "size_bytes",
        "content-type" => "content_type",
        "etag" => "md5_hash",
        "last-modified" => "last_modified_at",
        "x-timestamp" => "created_at",
        "x-delete-at" => "expires_at",
        "x-static-large-object" => "slo",
        "x-object-manifest" => "dlo_manifest",
      }

      OBJECT_WRITE_ATTRMAP = {
        # name in our model => name in create/update API request
        "content_type" => "Content-Type",
        # 'expires_at'     => 'X-Delete-At', # this is special-cased in update_object()
      }

      def object_map
        @object_map ||= class_map_proc(ObjectStorage::Object)
      end

      def object_metadata(container_name, object_path)
        return nil if container_name.blank? || object_path.blank?
        response =
          elektron_object_storage.head("#{container_name}/#{escapeURI(object_path)}")
        data = extract_object_header_data(response, container_name, object_path)
        object_map.call(data)
      end

      def object_content(container_name, object_path)
        body =
          elektron_object_storage.get("#{container_name}/#{escapeURI(object_path)}").body
        # default behavior from elektron -> converts returned json to an object
        # normaly thats fine but in some cases we want to download a json file
        # from the object storage if thats the case convert it back to json
        return body if body.is_a?(String)
        body.to_json
      end

      # NOTE: keep in mind there is a limit container_listing_limit
      def list_objects(container_name, options = {})
        # https://docs.openstack.org/api-ref/object-store/index.html?expanded=show-container-details-and-list-objects-detail

        # delimiter: The delimiter is a single character used to split object names to present a
        #            pseudo-directory hierarchy of objects. When combined with a prefix query, this enables
        #            API users to simulate and traverse the objects in a container as if they were in a directory tree.

        # prefix: Only objects with this prefix will be returned. When combined with a delimiter query,
        #         this enables API users to simulate and traverse the objects in a container as if they
        #         were in a directory tree.

        # path: For a string value, returns the object names that are nested in the pseudo path.
        #       Please use prefix/delimiter queries instead of using this path query.

        # prevent prefix and delimiter with slash, if this happens an empty list is returned

        list = elektron_object_storage.get(container_name, options).body
        result =
          list.map! do |o|
            object = map_attribute_names(o, OBJECTS_ATTRMAP)
            # path also serves as id() for Core::ServiceLayer::Model
            object["id"] = object["path"]
            object["container_name"] = container_name
            if object.key?("last_modified_at")
              # parse date
              object["last_modified_at"] = DateTime.iso8601(
                object["last_modified_at"],
              )
            end
            object
          end
        result
      end

      def list_objects_at_path(container_name, object_path, filter = {})
        # add trailing / to avaoid empty directorys
        # test/bla.txt
        # GET prefix: "test", delimiter: "/" -> this cause an empty result
        # GET prefix: "test/", delimiter: "/" -> this will find "bla.txt"
        object_path += "/" if !object_path.end_with?("/") && !object_path.empty?

        # result contains all folders with leading slash and without like
        # test/foo.txt
        # /test2/foo.txt
        # bla.txt
        #
        # prefix: "", delimiter: "/"
        # result = ["test/", "/", "bla.txt"]
        result =
          list_objects(
            container_name,
            filter.merge(prefix: object_path, delimiter: "/"),
          )

        # special case for leading slashes
        # remove "/" from result
        # result = ["test/","bla.txt"]
        root = result.select { |o| o["path"] == "/" }
        result.reject! { |o| o["path"] == "/" }
        # if found "/" then get results for prefix: "/", delimiter: "/"
        unless root.empty?
          result.concat(
            list_objects(
              container_name,
              filter.merge(prefix: "/", delimiter: "/"),
            ),
          )
        end
        # result = ["test/", "test2/", "bla.txt"]

        # if there is a pseudo-folder at `object_path`, it will be in the result, too;
        # filter this out since we only want stuff below `object_path`
        objects = result.reject { |obj| obj["id"] == object_path }
        objects.collect { |data| object_map.call(data) }
      end

      def list_objects_below_path(container_name, object_path, filter = {})
        list_objects(
          container_name,
          filter.merge(prefix: object_path),
        ).collect { |data| object_map.call(data) }
      end

      def copy_object(
        source_container_name,
        source_path,
        target_container_name,
        target_path,
        options = {}
      )
        header_attrs = {
          "Destination" => "/#{target_container_name}/#{target_path}",
        }.merge(options)
        elektron_object_storage.copy(
          "#{source_container_name}/#{escapeURI(source_path)}",
          headers: stringify_header_values(header_attrs),
        )
      end

      def move_object(
        source_container_name,
        source_path,
        target_container_name,
        target_path,
        options = {}
      )
        copy_object(
          source_container_name,
          source_path,
          target_container_name,
          target_path,
          options.merge(with_metadata: true),
        )
        elektron_object_storage.delete(
          "#{source_container_name}/#{escapeURI(source_path)}",
        )
      end

      def bulk_delete(targets)
        capabilities = list_capabilities
        if capabilities.attributes.key?("bulk_delete")
          # https://docs.openstack.org/swift/latest/middleware.html#bulk-delete
          # assemble the request object_list containing the paths to all targets

          # if targets more than the defined max deletes per request cut targest into half and try recursively
          bulk_delete = capabilities.bulk_delete
          if targets.length > bulk_delete["max_deletes_per_request"]
            left, right = targets.each_slice((targets.size / 2.0).round).to_a
            bulk_delete(left)
            targets = right
          end

          object_list = ""
          targets.each do |target|
            unless target.key?(:container)
              raise ArgumentError, "malformed target #{target.inspect}"
            end
            object_list += target[:container]
            object_list += "/" + target[:object] if target.key?(:object)
            object_list += "\n"
          end

          elektron_object_storage.post(
            "",
            "bulk-delete" => true,
            :headers => {
              "Content-Type" => "text/plain",
            },
          ) { object_list }
        else
          targets.each do |target|
            unless target.key?(:container)
              raise ArgumentError, "malformed target #{target.inspect}"
            end

            if target.key?(:object)
              delete_object(target[:container], target[:object])
            else
              delete_container(target[:container])
            end
          end
        end
      end

      def create_object(container_name, object_path, contents)
        object_path = sanitize_path(object_path)

        # content type "application/directory" is needed on pseudo-dirs for
        # staticweb container listing to work correctly
        header_attrs = {}
        if object_path.end_with?("/")
          header_attrs["Content-Type"] = "application/directory"
        end
        header_attrs["Content-Type"] = ""
        # Note: `contents` is an IO object to allow for easy future expansion to
        # more clever upload strategies (e.g. SLO); for now, we just send
        # everything at once
        elektron_object_storage.put(
          "#{container_name}/#{escapeURI(object_path)}",
          headers: stringify_header_values(header_attrs),
        ) { contents.read }
      end

      def delete_object(container_name, object, keep_segments = true)
        if keep_segments
          elektron_object_storage.delete("#{container_name}/#{object.path}")
        else
          if object.slo
            elektron_object_storage.delete(
              "#{container_name}/#{object.path}?multipart-manifest=delete",
            )
          elsif object.dlo
            # delete dlo manifest
            elektron_object_storage.delete("#{container_name}/#{object.path}")
            # delete segments container
            delete_folder(
              object.dlo_segments_container,
              object.dlo_segments_folder_path,
            )
          else
            elektron_object_storage.delete("#{container_name}/#{escapeURI(object.path)}")
          end
        end
        # return nil because nothing usable is returned from the API
        return nil
      end

      def update_object(object_path, params)
        container_name = params[:container_name]
        header_attrs = map_attribute_names(params, OBJECT_WRITE_ATTRMAP)

        unless params["expires_at"].nil?
          header_attrs["x-delete-at"] = params["expires_at"].getutc.strftime(
            "%s",
          )
        end

        (params["metadata"] || {}).each do |key, value|
          header_attrs["x-object-meta-#{key}"] = value
        end

        # stringify keys and values
        header_attrs.deep_merge!(header_attrs) { |_, _, v| v.to_s }
        header_attrs.stringify_keys!

        elektron_object_storage.post(
          "#{container_name}/#{escapeURI(object_path)}",
          headers: header_attrs,
        )
        # return nil because nothing usable is returned from the API
        nil
      end

      def create_folder(container_name, object_path)
        # a pseudo-folder is created by writing an empty object at its path, with
        # a "/" suffix to indicate the folder-ness
        elektron_object_storage.put(
          "#{container_name}/#{escapeURI(sanitize_path(object_path))}/",
          headers: {
            "Content-Type" => "application/directory",
          },
        )
      end

      def delete_folder(container_name, object_path)
        prefix = object_path
        prefix += "/" unless object_path.ends_with?("/")
        targets =
          list_objects_below_path(container_name, prefix).map do |obj|
            { container: container_name, object: obj.path }
          end
        bulk_delete(targets)
      end

      protected

      def extract_object_header_data(
        response,
        container_name = nil,
        object_path = nil
      )
        header_hash =
          map_attribute_names(extract_header_data(response), OBJECT_ATTRMAP)
        header_hash["id"] = header_hash["path"] = object_path
        header_hash["container_name"] = container_name
        header_hash["public_url"] = public_url(container_name, object_path)
        header_hash["last_modified_at"] = DateTime.httpdate(
          header_hash["last_modified_at"],
        ) # parse date
        header_hash["created_at"] = DateTime.strptime(
          header_hash["created_at"],
          "%s",
        ) # parse UNIX timestamp
        header_hash["expires_at"] = DateTime.strptime(
          header_hash["expires_at"],
          "%s",
        ) if header_hash.key?("expires_at") # optional!
        header_hash["metadata"] = extract_metadata_data(
          extract_header_data(response),
          "x-object-meta-",
        )
        header_hash
      end
    end
  end
end
