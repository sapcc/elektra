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

      @read_acls = parse_acl(read_acl_string)
      @write_acls = parse_acl(write_acl_string)

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

    def parse_acl acl_string = ""
      # https://docs.openstack.org/swift/latest/overview_acl.html#container-acls
      acl_data = {}

      acls = acl_string.split(',')
      acls.each do |acl|
        case acl 
        # standard reading cases
        when ".rlistings"
          acl_data[acl] = { 
            type: ".rlistings",
            operation: "listing access",
            user: "ANY", 
            project: nil, 
            token: false,
          }
        when ".r:*"
          acl_data[acl] = { 
            type: ".r:*", 
            operation: "access",
            user: "ANY",
            project: nil,
            token: false,
          } 
        else
          # all other special cases
          acl_parts = acl.split(':',2) # use split limit 2, this is needed because of "http://" in referer
          if acl_parts.length == 2
            case acl_parts[0]
            when ".r" 
              # .r:<referer>
              acl_data[acl] = { 
                type: ".r:<referer>", 
                operation: "access for referer #{acl_parts[1]}",
                user: nil,
                project: nil,
                referer: acl_parts[1],
                token: false,
              } 
            else
              # *:*
              if acl_parts[0] == '*' && acl_parts[1] == '*'
                acl_data[acl] = { 
                  type: ".*:*", 
                  operation: "access",
                  user: "ANY",
                  project: nil,
                  token: true,
                } 
              # <project-id>:<user-id>
              elsif acl_parts[0] != '*' and acl_parts[1] != '*'
                project = services.identity.find_project(acl_parts[0])
                user = services.identity.find_user(acl_parts[1])
                unless user.nil? || project.nil?
                  user_domain =  services.identity.find_domain(user.domain_id)
                  domain = services.identity.find_domain(project.domain_id)
                  acl_data[acl] = { 
                    type: "<project-id>:<user-id>", 
                    operation: "access",
                    user: "#{user_domain.name}/#{user.description} - #{user.name}",
                    project: "#{domain.name}/#{project.name}",
                    token: true,
                  } 
                else
                  if user.nil? && project.nil?
                    acl_data[acl] = { error: "cannot found project with PROJECT_ID #{acl_parts[0]} and user with USER_ID #{acl_parts[1]}" }
                  elsif project.nil?
                    acl_data[acl] = { error: "cannot found project with PROJECT_ID #{acl_parts[0]}"}
                  elsif user.nil?
                    acl_data[acl] = { error: "cannot found user with USER_ID #{acl_parts[1]}"}
                  else
                    acl_data[acl] = { error: "unkown parse error"}
                  end
                end
                  # <project-id>:*
              elsif acl_parts[0] != '*' and acl_parts[1] == '*'
                project = services.identity.find_project(acl_parts[0])
                unless project.nil?
                  domain = services.identity.find_domain(project.domain_id)
                  acl_data[acl] = { 
                    type: "<project-id>:*", 
                    operation: "access",
                    user: "ANY",
                    project: "#{domain.name}/#{project.name}",
                    token: true,
                  }
                else
                  acl_data[acl] = { error: "cannot found project with PROJECT_ID #{acl_parts[0]}" }
                end
                  # *:<user-id>
              elsif acl_parts[0] == '*' and acl_parts[1] != '*'
                user = services.identity.find_user(acl_parts[1])
                unless user.nil?
                  user_domain =  services.identity.find_domain(user.domain_id)
                  acl_data[acl] = { 
                    type: "*:<user-id>", 
                    operation: "access",
                    user: "#{user_domain.name}/#{user.description} - #{user.name}",
                    project: nil,
                    token: true,
                  }
                else
                  acl_data[acl] = { error: "cannot found user with USER_ID #{acl_parts[1]}" }
                end
              end
            end
          else
            unless acl.include? ":" or acl.include? "*"
              # <role_name>
              acl_data[acl] = "A user with the specified role name '#{acl}' has access on the container."
            else
              acl_data[acl] ={ error: "cannot parse acl" }
            end
          end          
        end
      end

      pp acl_data
      return acl_data
    end

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
