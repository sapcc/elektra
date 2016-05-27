module ViewHelper
  def project_id_and_name(project)
    if project
      "#{project} (#{@service_user.find_project_by_name_or_id(project).name})"
    else
      'N/A'
    end
  end
end
