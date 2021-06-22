module EmailService
  module TemplateHelper

    # include AwsSesHelper

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
          errors.push({ name: "name", message: "Source can't be empty" })
        elsif opts[:name].match(/(\w\s)+/)
          errors.push({ name: "name", message: "Name can't have space, allowed separators are '-' and '_' " })
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

    end # Template Class ends
    
    # Stuff outside Template Class 
    def new_template(attributes = {})
      template = Template.new(attributes)
    end

  end
end


