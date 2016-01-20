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
    
    # render project tree
    def subprojects_tree(subprojects,auth_projects, html_options={})
      auth_projects = auth_projects.inject({}){|hash,pr| hash[pr.id] = pr; hash } unless auth_projects.is_a?(Hash)
      
      content_tag(:ul, class: html_options[:class] ) do
        if subprojects.is_a?(Array)
          subprojects.map do |subproject|
            content_tag(:li, link_to( subproject.name, plugin('identity').project_path(project_id: subproject.id)), id: subproject.id)
          end.join("\n").html_safe
        elsif subprojects.is_a?(Hash)
          result = []
          
          subprojects.each do |k,v|
            result <<  content_tag(:li, id: k) do
              project = auth_projects[k]
              next if project.nil?
              capture do
                concat link_to project.name, plugin('identity').project_path(project_id: project.id)
                if v.is_a?(Hash)
                  concat subprojects_tree(v,auth_projects)
                end
              end if project
            end
          end
          result.join("\n").html_safe
        end
      end
    end
  end
end
