module EmailService
  module TemplateHelper

    # Attempt to parse using regex the template data
    def get_template_items
      template_regex = /\{{\K[^\s}}]+(?=}})/
      subject = "Subscription Preferences for {{contact.firstName}} {{contact.lastName}}"
      html_part = "<!doctype html><html><head><meta charset='utf-8'></head><body><h1>Your Preferences</h1> <p>You have indicated that you are interested in receiving information about the following subjects:</p> <ul> {{#each subscription}} <li>{{interest}}</li> {{/each}} </ul> <p>You can change these settings at any time by visiting the <a href=https://www.example.com/preferences/i.aspx?id={{meta.userId}}> Preference Center</a>.</p></body></html>"
      text_part = "Your Preferences\n\nYou have indicated that you are interested in receiving information about the following subjects:\n {{#each subscription}} - {{interest}}\n {{/each}} \nYou can change these settings at any time by visiting the Preference Center at https://www.example.com/prefererences/i.aspx?id={{meta.userId}}"
      # to get first occurance
      # @subject_match = subject.match(template_regex)
      # to get all occurances
      @subject_match = subject.scan(template_regex)
      @html_part_match = html_part.scan(template_regex)
      @text_part_match = text_part.scan(template_regex)
    end

    # Get templates name as a collection to be rendered
    def get_templates_collection(templates)
      templates_collection = []
      if !templates.empty?
        templates.each do |template|
          templates_collection << template[:name]
        end
      end
      templates_collection
    end
    
     def list_templates(token="")
      tmpl_hash = Hash.new
      templates = []
      begin
        ses_client = create_ses_client
        template_list = ses_client.list_templates({
          next_token: token,
          max_items: 10,
        })
        next_token = template_list.next_token
        index = 0
        while template_list.size > 0 && index < template_list.templates_metadata.count
            resp = ses_client.get_template({
              template_name: template_list.templates_metadata[index].name,
            })
            tmpl_hash = { 
              :id => index,
              :name => resp.template.template_name,
              :subject => resp.template.subject_part,
              :text_part => resp.template.text_part,
              :html_part => resp.template.html_part 
            }
            templates.push(tmpl_hash)
            index = index + 1
        end

      rescue Aws::SES::Errors::ServiceError => error
        msg = "Unable to fetch templates. Error message: #{error}"
        logger.debug "CRONUS: DEBUG: #{msg}"
        flash.now[:alert] = msg
      end
      return next_token, templates
    end


    def get_all_templates
      templates = []
      next_token, templates = list_templates
      while next_token 
        next_token, templates_set = list_templates(next_token)
        templates += templates_set
      end
      return templates
    end


    def find_template(name)
      templates = get_all_templates
      template = new_template({})
      templates.each do |t|
        if t[:name] == name 
          template = new_template(t)
          return template
        end
      end
    end

    def store_template(tmpl)
      status = " "
      ses_client = create_ses_client
      begin
        resp = ses_client.create_template({
          template: {
            template_name: tmpl.name,
            subject_part: tmpl.subject,
            text_part: tmpl.text_part,
            html_part: tmpl.html_part,
          },
        })
        audit_logger.info(current_user, 'has created a template ', tmpl.name)
        msg = "Template #{tmpl.name} is saved"
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        msg = "Unable to save template: #{error}"
        status = msg
      end
      logger.debug "CRONUS: DEBUG: #{msg} "
      status
    end

    def delete_template(tmpl_name)
      status = ""
      begin
        ses_client = create_ses_client
        resp = ses_client.delete_template({
            template_name: tmpl_name,
        })
        msg = "Template #{tmpl_name} is deleted."
        audit_logger.info(current_user, 'has deleted template ', tmpl_name)
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
         msg = "Unable to delete template #{name}. Error message: #{error} "
        status = msg
      end
      logger.debug "#{msg}"
      status
    end

    def update_template(name, subject, html_part, text_part)
      begin
        ses_client = create_ses_client
        resp = ses_client.update_template({
          template: {
            template_name: name, 
            subject_part: subject,
            text_part: text_part,
            html_part: html_part,
          },
        })
        audit_logger.info(current_user, 'has updated template ', name)
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        msg = "Unable to update template #{name}. Error: #{error}"
        status = msg
      end
     status
    end

    class Template 
      def initialize(opts = {})
        @name       = opts[:name]
        @subject    = opts[:subject]
        @html_part  = opts[:html_part]
        @text_part  = opts[:text_part]
        @errors     = validate_template(opts)
      end 
    
      def name
        @name
      end

      def subject
        @subject
      end

      def html_part
        @html_part
      end

      def text_part
        @text_part
      end

      def errors
        @errors
      end

      def errors?
        @errors.empty? ? false : true
      end

      def validate_template(opts)
        errors = []
        if opts[:name] == "" || opts[:name].nil?
          errors.push({ name: "name", message: "Template name can't be empty" })
        elsif opts[:name].match(/(\w\s)+/)
          errors.push({ name: "name", message: "Template name can't have space, allowed separators are '-' and '_' " })
        end
        if opts[:subject] == "" || opts[:subject].nil?
          errors.push({ name: "subject", message: "Subject can't be empty" })
        end
        if opts[:html_part] == "" || opts[:html_part].nil?
          errors.push({ name: "html_part", message: "Html body can't be empty" })
        end
        if opts[:text_part] == "" || opts[:text_part].nil?
          errors.push({ name: "text_part", message: "Text body can't be empty" })
        end
        errors
      end

    end
    

    def new_template(attributes = {})
      template = Template.new(attributes)
    end

    def pretty_print_html(input)
      html_output = Nokogiri::HTML(input)
    end
  end
end


