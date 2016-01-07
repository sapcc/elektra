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

  def body_class
    css_class = controller.controller_name
    page_id = params[:id].split('/').last if params[:id]
    css_class = "#{css_class} #{page_id}" if css_class == "pages"
    css_class
  end

  def external_link_to(name, url)
    haml_tag :a, href: url do
      # haml_tag :span, class: "glyphicon glyphicon-share-alt"
      haml_tag :span, class: "fa fa-external-link"
      haml_concat name
    end
  end

  def context_name
    context = "Domain"
    if @scoped_project_id
      context = "Project"
    end
    context
  end

end
