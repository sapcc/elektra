module EmailService
  module TemplateHelper

    include AwsSesHelper

    class EmailTemplate
      Template = Struct.new(:name, :subject, :html_part, :text_part)
      attr_accessor :template
      def initialize(opts)
        @template = Template.new(opts[:name], opts[:subject], opts[:html_part], opts[:text_part] )
      end
    end

    def new_template(attributes = {})
      template = EmailTemplate.new(attributes)
    end

  end
end


