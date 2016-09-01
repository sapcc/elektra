module ViewHelper
  def project_id_and_name(project)
    if project
      # try to find project in friendly ids
      remote_project = FriendlyIdEntry.find_by_class_scope_and_key_or_slug('Project',@scoped_domain_id,project)
      # project not found in friendly ids -> load from api
      remote_project = @service_user.find_project_by_name_or_id(project) unless remote_project
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
