module Webconsole
  class ApplicationController < DashboardController
    def show
      @token = current_user.token
      @webcli_endpoint = current_user.service_url("webcli")
      @identity_url = current_user.service_url("identity")
    end
    
    # returns current context 
    def current_context
      result = {
        token: current_user.token,
        webcli_endpoint: current_user.service_url("webcli"),
        identity_url: current_user.service_url("identity")
      }
      
      # get plugin specific help content
      plugin_path = params[:plugin_path]
      # remove leading slash
      plugin_path.sub!(/^\//, '')
      
      # find plugin by mount point (plugin_path)
      plugin = catch (:found)  do
        Core::PluginsManager.available_plugins.each do |plugin|
          throw :found, plugin if plugin_path.start_with?(plugin.mount_point)
        end
      end
      
      # get name of the specific service inside the plugin
      # remove plugin name from path
      path = plugin_path.split('/')
      path.shift
      service_name = path.join('_')
      
      # try to find the help file
      help_file = File.join(plugin.path,"webconsole_#{service_name}_help.md")
      help_file = File.join(plugin.path,"webconsole_help.md") unless File.exists?(help_file)
      help_file = File.join(Rails.root,"plugins/webconsole/webconsole_help.md") unless File.exists?(help_file)

      if File.exists?(help_file)
        source = File.new(help_file, "r").read
        source = source.gsub('#{@scoped_domain_name}', @scoped_domain_name.gsub(/_/,'\_'))
                       .gsub('#{@scoped_project_name}',@scoped_project_name.gsub(/_/,'\_'))
                       .gsub('#{@token}',current_user.token)
          
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
        result[:help_html] = markdown.render(source)
      end
   
      render json: result
    end
    
    def redirect_to(options = {}, response_status = {})
      if request.xhr?
        head :ok, location: url_for(options)
      else
        super options, response_status
      end
    end
  end
end