module ViewHelper
  def project_id_and_name(project)
    if project
      remote_project = @service_user.find_project_by_name_or_id(project)
      # projects where the service user does not have permissions or deleted projects get 'N/A'
      project_name = remote_project ? remote_project.name : ''
      # "#{project} (#{project_name})"
      unless project_name.blank?
        haml_concat "#{project_name}"
        haml_tag :br
      end
      haml_tag :span, class: "info-text" do
        haml_concat "#{project}"
      end
    else
      haml_concat 'N/A'
    end
  end
end
