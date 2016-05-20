module ViewHelper
  def project_id_and_name(project)
    if project
      "#{project} (#{services.identity.find_project(project).name})"
    else
      'N/A'
    end
  end
end
