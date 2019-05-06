module Webconsole
  class ApplicationController < DashboardController
    include UrlHelper

    authorization_context 'webconsole'
    # enforce permission checks. This will automatically
    # investigate the rule name.
    authorization_required

    def show
      @token = current_user.token
      @webcli_endpoint = "https://ccloudshell.eu-de-2.cloud.sap" # TODO: Replace endpoint url with catalog entry
      @identity_url = current_user.service_url("identity")
      @region = current_region
      @user_name = current_user.name
    end

    # returns current context
    def current_context
      # TODO: Replace endpoint url with catalog entry
      result = {
        token: current_user.token,
        webcli_endpoint: "https://ccloudshell.eu-de-2.cloud.sap",
        identity_url: current_user.service_url("identity"),
        region: current_region,
        user_name: current_user.name
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
        # load general help content
        general_help_file = File.join(Rails.root,"plugins/webconsole/webconsole_general_help.md")
        general_help_source = File.new(general_help_file, "r").read if File.exists?(general_help_file)
        # replace placeholders inside this contet
        general_help_source = general_help_source.gsub('#{@scoped_domain_name}',  @scoped_domain_name)
                                                 .gsub('#{@scoped_project_name}', @scoped_project_name)
                                                 .gsub('#{@active_project.id}',   @active_project.id)
                                                 .gsub('#{@token}',               current_user.token)
                                                 .gsub('#{@sap_docu_url}',        sap_url_for('documentation'))
        # load plugin specific help content
        source = File.new(help_file, "r").read
        # create renderer
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

        # concat and bind general and specific help contents
        result[:help_html] = "#{markdown.render(general_help_source)}#{markdown.render(source)}"
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
