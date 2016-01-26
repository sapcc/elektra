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
    
    def breadcrumb(current_project,auth_projects,&block)
      parents_project_ids = current_project.parents_project_ids.compact
      auth_projects = auth_projects.inject({}){|hash,pr| hash[pr.id] = pr; hash } unless auth_projects.is_a?(Hash)
      
      breadcrum_projects = parents_project_ids.reverse.inject([]) do |array,project_id|
        project = auth_projects[project_id] 
        if project
          block.call(project,array.length==0) if block_given?
          array << project 
        end
        array
      end
    end
    
    def current_project_tree(current_project, auth_projects, options={})
      tree = current_project.subprojects_ids
      tree = {current_project.id => tree}
      current_project.parents_project_ids.compact.each{|key| tree = {key=>tree}}
      
      capture do 
        concat subprojects_tree(tree,auth_projects,options.merge(current_project: current_project))
      end
    end
    
    # render project tree
    def subprojects_tree(subprojects,auth_projects, options={})
      auth_projects = auth_projects.inject({}){|hash,pr| hash[pr.id] = pr; hash } unless auth_projects.is_a?(Hash)
      
      content_tag(:ul, class: options.delete(:class) ) do
        if subprojects.is_a?(Array)
          subprojects = subprojects.compact
          subprojects.map do |subproject_id|
            project = auth_projects[subproject_id]
            next if project.nil? or project.id.nil?
            if options[:current_project] and options[:current_project].id==project.id
              content_tag(:li, options[:current_project].name, class: 'current-project')
            else
              content_tag(:li, link_to( subproject.name, plugin('identity').project_path(project_id: subproject.id)), id: subproject.id)
            end
          end.join("\n").html_safe
          
        elsif subprojects.is_a?(Hash)
          result = []
         
          # remove unauthorized project keys. Empty
          subprojects = subprojects.inject({}) do |hash,(k,v)| 
            auth_projects[k].nil? ? (v.each{|sub_k,sub_v| hash[sub_k]=sub_v} if v.is_a?(Hash)) : hash[k]=v
            hash
          end
          
          subprojects.each do |k,v|
            project = auth_projects[k]

            if project or v.is_a?(Hash)
              is_current_project = (options[:current_project] and options[:current_project].id==project.id)

              result <<  content_tag(:li, id: k, class: is_current_project ? 'current-project' : '') do
                capture do
                  if is_current_project
                    concat project.name 
                  else
                    concat link_to project.name, plugin('identity').project_path(project_id: project.id) 
                  end
                  if v.is_a?(Hash)
                    concat subprojects_tree(v,auth_projects,options)
                  end
                end
              end if project
            end
          end
          result.join("\n").html_safe
        end
      end
    end
        
    def parents_tree(parents_project_ids,auth_projects, options={})
      parents_project_ids = parents_project_ids.compact
      auth_projects = auth_projects.inject({}){|hash,pr| hash[pr.id] = pr; hash } unless auth_projects.is_a?(Hash)
      
      if parents_project_ids and parents_project_ids.length>0
        content_tag(:ul, class: options[:class] ) do
          project_id = parents_project_ids.last
          new_parents_project_ids = parents_project_ids[0..-2]
          project = auth_projects[project_id]
          
          project = nil if (project and project.name=='Project 1_1_1')
          
          capture do
            if options[:current_project] and options[:current_project].id==project.id
              concat content_tag(:li, options[:current_project].name, class: 'current-project')
            else
              concat content_tag(:li, link_to( project.name, plugin('identity').project_path(project_id: project.id)), id: project.id) if project
            end
            concat parents_tree(new_parents_project_ids, auth_projects)
          end
        end
      end
    end

  end
end
