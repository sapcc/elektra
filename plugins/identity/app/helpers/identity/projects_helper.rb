module Identity
  module ProjectsHelper
    
    # This method loads remote projects via ajax into a new created div.
    def remote_projects(options={})
      content_tag(:div, '',class: 'projects-widget', id: SecureRandom.hex, data: {
        widget: 'projects',
        url: plugin('identity').projects_path(),
        per_page: options[:per_page] || 3,
        filter: (options[:filter] || {}).to_json
      })
    end
  end
end
