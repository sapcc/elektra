class JumpController < ::ApplicationController
  def index
    project = ObjectCache.where(
                cached_object_type: 'project', 
                id: params[:project_id]
              ).first || cloud_admin.identity.find_project(params[:project_id])

    unless project
      render html: "Could not find project with id #{params[:project_id]}"
      return
    end
  
    path = "/#{project.domain_id}/#{project.id}"
    path += params[:service] ? "/#{params[:service]}" : '/home' 
    path += "/#{params[:resource]}" if params[:resource] 
    path += "/#{params[:extra]}" if params[:extra]
    redirect_to(path)
  end
end
