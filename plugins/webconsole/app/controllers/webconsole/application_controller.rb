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
      
      help_file = File.join(Rails.root,"plugins/#{params[:plugin_name]}/webconsole_help.md")
      help_file = File.join(Rails.root,"plugins/webconsole/webconsole_help.md") unless File.exists?(help_file)
      
      if File.exists?(help_file)
        source = File.new(help_file, "r").read
        source = source.gsub('#{@scoped_domain_name}',@scoped_domain_name)
                       .gsub('#{@scoped_project_name}',@scoped_project_name)
                       .gsub('#{@token}',current_user.token)
          
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
        result[:help_html] = markdown.render(source)
      end
   
      render json: result
    end
  end
end