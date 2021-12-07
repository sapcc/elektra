module EmailService
  module TemplateHelper

    ## moved from aws_helper.rb on 15 Nov 2021
     #### TEMPLATES ###

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
        # logger.debug "CRONUS: DEBUG: template_list SIZE : #{template_list.templates_metadata.count}"
        while template_list.size > 0 && index < template_list.templates_metadata.count
            resp = ses_client.get_template({
            template_name: template_list.templates_metadata[index].name,
            })
            tmpl_hash = { :id => index, :name => resp.template.template_name, :subject => resp.template.subject_part, :text_part => resp.template.text_part, :html_part => resp.template.html_part }
            templates.push(tmpl_hash)
            index = index + 1
        end

      rescue Aws::SES::Errors::ServiceError => error
        msg = "Unable to fetch templates. Error message: #{error}"
        logger.debug "CRONUS: DEBUG: #{msg}"
        flash.now[:alert] = msg # TODO: fix this flash
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
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
         msg = "Unable to delete template #{name}. Error message: #{error} "
        status = msg
      end
      logger.debug "#{msg}"
      status
    end

    def update_template(name, subject, html_part, text_part)
      # logger.debug "#{name} : #{subject} : #{html_part} : #{text_part} "
      begin
        ses_client = create_ses_client
        resp = ses_client.update_template({
          template: { # required
            template_name: name,  # "TemplateName", # required
            subject_part: subject, # "SubjectPart",
            text_part: text_part, # "TextPart",
            html_part: html_part, #"HtmlPart",
          },
        })
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        msg = "Unable to update template #{name}. Error: #{error}"
        status = msg
      end
     status
    end
    ## moved from aws_helper.rb on 15 Nov 2021

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


