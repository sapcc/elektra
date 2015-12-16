module Identity
  module ProjectsHelper
    
    # This method loads remote projects via ajax into a new created div.
    def remote_projects(options={})
      container_id = SecureRandom.hex
      
      content_tag(:div, id: container_id) do
        content_tag(:div, '', data: {
          update_path: plugin('identity').projects_path({
            per_page: (options[:per_page] || 3), 
            filter: (options[:filter] || {}), 
            partial: true 
          }),
          update_immediately: true
        })
      end
      
    end
  end
end
