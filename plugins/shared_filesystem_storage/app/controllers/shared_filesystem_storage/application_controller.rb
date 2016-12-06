module SharedFilesystemStorage
  class ApplicationController < ::DashboardController
    # add project_id to default policy params (needed by policy rules). 
    before_filter do
      @policy_default_params ||= { }
      @policy_default_params[:project_id] = @scoped_project_id
    end
    
    # set policy context
    authorization_context 'shared_filesystem_storage'
    # enforce permission checks. This will automatically investigate the rule name.
    authorization_required
    
    # catch security violation errors
    rescue_from MonsoonOpenstackAuth::Authorization::SecurityViolation do |e|
      m = e.message
      if e.involved_roles and e.involved_roles.is_a?(Array) and e.involved_roles.length>0
        m += " Please check (user profile or role assignments) if you have one of the following roles: #{e.involved_roles.flatten.join(', ')}." 
      end 
      m
      
      respond_to do |format|
        format.json {render json: {error: m}, status: :unauthorized} 
        format.html {
          render_error_page(e, title: 'Unauthorized', description: m)
        }
      end
    end
    
    def show
      @permissions = {
        shares: {
          list: current_user.is_allowed?("shared_filesystem_storage:share_list"),
          create: current_user.is_allowed?("shared_filesystem_storage:share_create")
        },
        snapshots: { 
          list: current_user.is_allowed?("shared_filesystem_storage:snapshot_list"),
          create: current_user.is_allowed?("shared_filesystem_storage:snapshot_create")
        },
        share_networks: {
          list: current_user.is_allowed?("shared_filesystem_storage:share_network_list"),
          create: current_user.is_allowed?("shared_filesystem_storage:share_network_create")
        }
      }
    end
  end
end