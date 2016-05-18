module ViewHelper
  def project_id_and_name(project)
    "#{project} (#{services.identity.find_project(project).name})"
  end
end
