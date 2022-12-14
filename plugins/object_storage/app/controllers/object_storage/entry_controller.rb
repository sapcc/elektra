module ObjectStorage
  class EntryController < ObjectStorage::ApplicationController
    authorization_required

    def index
      # if the user is allowed to list containers, continue to the actual UI
      if current_user.is_allowed?("object_storage:container_list")
        # check existing account
        # if "account_autocreate" on swift proxy is active and no accout is exsiting it will create a new account here
        unless services.object_storage.account
          # check that account management is allowed otherwise we are in trouble
          capabilities = services.object_storage.list_capabilities
          if capabilities.swift["allow_account_management"]
            if services.resource_management.available?
              render action: "no_swift_account_because_no_quota"
            end
          else
            render action: "no_swift_account_and_account_management"
          end
        else
          # check allow_account_management
          redirect_to plugin("object_storage").containers_path
        end
        return
      end

      # special case for monsoon2 legacy: explain how to enable Swift for legacy projects
      if @scoped_domain_name == "monsoon2"
        render action: "howtoenable_monsoon2"
      else
        render action: "howtoenable"
      end
    end
  end
end
