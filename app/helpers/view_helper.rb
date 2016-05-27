module ViewHelper
  def project_id_and_name(project)
    if project
      remote_project = @service_user.find_project_by_name_or_id(project)
      # projects where the service user does not have permissions or deleted projects get 'N/A'
      project_name = remote_project ? remote_project.name : 'N/A'
      "#{project} (#{project_name})"
    else
      'N/A'
    end
  end
end
