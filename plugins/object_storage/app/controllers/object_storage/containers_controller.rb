module ObjectStorage
  class ContainersController < ObjectStorage::ApplicationController
    authorization_required
    before_action :load_container, except: [ :index, :new, :create ]
    before_action :load_quota_data, only: [ :index, :show ]

    def index
      @capabilities = services.object_storage.list_capabilities
      @containers   = services.object_storage.containers
    end

    def show
      # for the "Object versioning" feature, we need to offer a selection of container names,
      # but to avoid confusion, the archive container should be different from the current one
      @other_container_names = services.object_storage.containers.map(&:name).reject { |n| n == @container.name }
    end

    def check_acls
      read_acl_string = params[:read_acl] || ""
      write_acl_string = params[:write_acl] || ""

      # https://docs.openstack.org/swift/latest/overview_acl.html#container-acls
      # parse read_acl
      read_acl_data = {}
      read_acls = read_acl_string.split(',')
      read_acls.each do |read_acl|
        puts read_acl
        case read_acl 
        when ".rlistings"
          read_acl_data[".rlistings"] = "Any user can perform a HEAD or GET operation on the container provided the user also has read access on objects."
        when ".r:*"
          read_acl_data[".r:*"] = "Any user has access to objects. No token is required in the request."
        else
          # all other special cases
          read_acl_parts = read_acl.split(':')
          case read_acl_parts[0]
          when ".r" 
            read_acl_data[".r"] = "The referrer #{read_acl_parts[1]} has granted access to objects. The referrer is identified by the Referer request header in the request. No token is required."
          else
            project_uuid = read_acl_parts[0]
            referrer = read_acl_parts[1]
            puts referrer
            if referrer == "*"
             read_acl_data[project_uuid] = "Any user for Project #{project_uuid} has access to objects. Token is required in the request."
            else
             read_acl_data[project_uuid] = "The referrer #{referrer} has granted access to objects. But only user for Project #{project_uuid} has access to objects. The referrer is identified by the Referer request header in the request. Token is required in the request."
            end
          end
         end
       end

      render json: {
        read_acl: read_acl_data,
        write_acl: "foo"
      }
    end

    def confirm_deletion
      @form = ObjectStorage::Forms::ConfirmContainerAction.new()
      @empty = services.object_storage.empty?(@container.name)
    end

    def confirm_emptying
      @form = ObjectStorage::Forms::ConfirmContainerAction.new()
      @empty = services.object_storage.empty?(@container.name)
    end

    def show_access_control
    end

    def update_access_control
      attrs = params.require(:container).permit(:read_acl, :write_acl)
      unless @container.update_attributes(attrs)
        render action: 'show_access_control'
        return
      end
      back_to_container_list
    end

    def new
      @container = services.object_storage.new_container(name: "")
    end

    def pre_empty
      # needed to render pre_empty.js
      @container_id = Digest::SHA1.hexdigest(@container.name)
      @encoded_container_name = params[:id]

      @form = ObjectStorage::Forms::ConfirmContainerAction.new(params.require(:forms_confirm_container_action))
      unless @form.validate
        render action: 'confirm_emptying'
        return
      end
    end

    def empty
      # needed to render empty.js
      @container_id = Digest::SHA1.hexdigest(@container.name)

      # trigger bulk delete
      services.object_storage.empty(@container.name)
    end

    def create
      @container = services.object_storage.new_container(params.require(:container))
      unless @container.save
        render action: 'new'
        return
      end

      back_to_container_list
    end

    def update
      @container.metadata = self.metadata_params
      attrs = params.require(:container).permit(:object_count_quota, :bytes_quota, :versions_location, :has_versions_location, :has_web_index, :web_index, :web_file_listing)

      # normalize "has_versions_location" to Boolean
      attrs[:has_versions_location] = attrs[:has_versions_location] == '1'
      # clear "versions_location" if disabled
      attrs[:versions_location]     = '' unless attrs[:has_versions_location]

      if attrs.delete(:has_web_index) != '1'
        attrs[:web_index] = '' # disable web_index if unselected in UI
      end

      attrs[:web_file_listing] = attrs[:web_file_listing] == '1'

      unless @container.update_attributes(attrs)
        @other_container_names = services.object_storage.containers.map(&:name).reject { |n| n == @container.name }
        render action: 'show' # "edit" view is covered by "show"
        return
      end

      back_to_container_list
    end

    def destroy
      @form = ObjectStorage::Forms::ConfirmContainerAction.new(params.require(:forms_confirm_container_action))
      unless @form.validate
        render action: 'confirm_deletion'
        return
      end

      @container.destroy
      back_to_container_list
    end

    private

    def load_container
      # to prevent problems with weird container names like "echo 1; rm -rf *)"
      # the name is form encoded and must be decoded here
      @container_name = URI.decode_www_form_component(params[:id])
      @container = services.object_storage.container_metadata(@container_name)
      raise ActiveRecord::RecordNotFound, "container #{params[:id]} not found" unless @container
    end

    def back_to_container_list
      respond_to do |format|
        format.js do
          @containers = services.object_storage.containers
          render action: 'reload_container_list'
        end
        format.html { redirect_to plugin('object_storage').containers_path }
      end
    end

  end
end
