module ObjectStorage
  class EntryController < ObjectStorage::ApplicationController

    authorization_required

    def index
      # if the user is allowed to list containers, continue to the actual UI
      if current_user.is_allowed?('object_storage:container_list')
        if services.object_storage.account_status.status == 404
          render action: 'no_swift_account'      
        else
          redirect_to plugin('object_storage').containers_path
        end
        return
      end

      # special case for monsoon2 legacy: explain how to enable Swift for legacy projects
      if services.identity.find_domain(@scoped_domain_id).name == 'monsoon2'
        render action: 'howtoenable_monsoon2'
      else
        render action: 'howtoenable'
      end
    end

  end
end
