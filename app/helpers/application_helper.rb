module ApplicationHelper

  # This class is used to create scoped urls for plugin url helpers
  class PluginUrlHelper
    # caching, do not create a plugin helper twice
    def self.plugin_helper(helper,plugin_name,scope)
      @@plugin_helpers ||= {}
      helper = @@plugin_helpers[plugin_name] ||= new(helper,plugin_name)
      helper.scope=scope
      helper
    end

    attr_accessor :scope
    # helper is ApplicationHelper, scope is a hash ({domain_id: DOMAIN_ID, project_id: PROJECT_ID})
    def initialize(helper,plugin_name)
      @plugin_name     = plugin_name
      @plugin          = helper.send("#{plugin_name}_plugin")
      @main_app        = helper.main_app
    end

    # delegate all methods to the plugin_helper. Clean the scope parameters before delegation!
    def method_missing(method,*args,&block)
      if method.to_s.ends_with?('_path') or method.to_s.ends_with?('_url')
        # extract options (last args hash member)
        options = args.extract_options!

        # build the scope (delete scope values from options)
        @scope[:domain_id] = options.delete(:domain_id) if options.has_key?(:domain_id)
        @scope[:project_id] = options.delete(:project_id) if options.has_key?(:project_id)
        @scope.delete_if{|key, value| value.nil? }

        # add prefix to the path
        options[:script_name] = @main_app.send("#{@plugin_name}_plugin_path",@scope)
        args << options

        # build the path
        @plugin.send(method,*args)
      else
        @plugin.send(method,*args,&block)
      end
    end
  end

  def plugin(name)
    if plugin_available?(name)
      PluginUrlHelper.plugin_helper(self,name,{domain_id: @scoped_domain_fid, project_id: @scoped_project_fid})
    end
  end

  def plugin_available?(name)
    self.respond_to?("#{name}_plugin".to_sym)
  end




  # ---------------------------------------------------------------------------------------------------
  # Breadcrumb/Hierarchy Helpers
  # ---------------------------------------------------------------------------------------------------


  def hierarchical_breadcrumb(active_project, auth_projects)
    unless active_project.blank?
      parents_project_ids = active_project.parents_project_ids
      breadcrumb_projects = Array.new

      # blank check necessary for root projects
      unless parents_project_ids.blank?
        parents_project_ids.compact!
        auth_projects = auth_projects.inject({}){|hash,pr| hash[pr.id] = pr; hash } unless auth_projects.is_a?(Hash)

        breadcrumb_projects = parents_project_ids.reverse.inject([]) do |array,project_id|
          project = auth_projects[project_id]
          if project
            yield(project) if block_given? # if block given do this
            array << project               # this is for the case that no block is given: just add to array
          end
          array
        end
      end

      # add active project to the end of the project list
      yield(active_project) if block_given?
      breadcrumb_projects << active_project
    end
  end

  def active_project_tree(active_project, auth_projects, options={})
    tree = active_project.subprojects_ids
    tree = {active_project.id => tree}
    parent_ids = active_project.parents_project_ids
    unless parent_ids.blank?
      parent_ids.compact.each{|key| tree = {key=>tree}}
    end

    capture do
      concat subprojects_tree(tree,auth_projects,options.merge(active_project: active_project))
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
          if options[:active_project] and options[:active_project].id==project.id
            content_tag(:li, options[:active_project].name, class: 'current-project')
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
            is_active_project = (options[:active_project] and options[:active_project].id==project.id)

            result <<  content_tag(:li, id: k, class: is_active_project ? 'current-project' : '') do
              capture do
                if is_active_project
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
    unless parents_project_ids.blank?
      parents_project_ids = parents_project_ids.compact
      auth_projects = auth_projects.inject({}){|hash,pr| hash[pr.id] = pr; hash } unless auth_projects.is_a?(Hash)

      if parents_project_ids and parents_project_ids.length>0
        content_tag(:ul, class: options[:class] ) do
          project_id = parents_project_ids.last
          new_parents_project_ids = parents_project_ids[0..-2]
          project = auth_projects[project_id]

          project = nil if (project and project.name=='Project 1_1_1')

          capture do
            if options[:active_project] and options[:active_project].id==project.id
              concat content_tag(:li, options[:active_project].name, class: 'current-project')
            else
              concat content_tag(:li, link_to( project.name, plugin('identity').project_path(project_id: project.id)), id: project.id) if project
            end
            concat parents_tree(new_parents_project_ids, auth_projects)
          end
        end
      end
    end
  end




  # ---------------------------------------------------------------------------------------------------
  # Favicon Helpers
  # ---------------------------------------------------------------------------------------------------

  def favicon_png
    capture_haml do
      haml_tag :link, rel: "icon", type: "image", href: image_path("favicon.png")
    end
  end

  def favicon_ico
    capture_haml do
      haml_tag :link, rel: "shortcut icon", type: "image/x-icon", href: image_path("favicon.ico")
    end
  end


  def apple_touch_icon
    capture_haml do
      haml_tag :link, rel: "apple-touch-icon", href: image_path("apple-touch-icon.png")
    end
  end


  # ---------------------------------------------------------------------------------------------------
  # Text Helpers
  # ---------------------------------------------------------------------------------------------------

  def processed_controller_name
    name = controller.controller_name
    return "Services" if name == "pages"

    name.humanize
  end

  def selected_service_name
    name = active_navigation_item_name(context: :services, :level => :all)
    if name.blank?
      name = "Services"
    end
    name
  end

  def selected_admin_service_name
    name = active_navigation_item_name(context: :admin, :level => :all)
    if name.blank?
      name = "Admin"
    end
    name
  end

  def active_service_breadcrumb
    active_service = active_navigation_item_name(context: :services, :level => :all)
    crumb = "Home" # Default case, only visible on domain home page
    if active_service.blank?
      crumb = "Project Overview" unless @active_project.blank? # no service selected, if project is available this is the project home page -> print project name
    else
      crumb = active_service # print active service name
    end
    crumb
  end

  def body_class
    css_class = controller.controller_name

    page_id = params[:id].split('/').last if params[:id]
    css_class << " #{page_id}" if css_class == "pages"

    css_class
  end

  def external_link_to(name, url)
    haml_tag :a, href: url do
      # haml_tag :span, class: "glyphicon glyphicon-share-alt"
      haml_tag :span, class: "fa fa-external-link"
      haml_concat name
    end
  end

end
