module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups
    module BeforeFieldHtml
      # Name of the component method
      def before_field_html(wrapper_options = nil)
        @before_field_html ||=
          begin
            if options[:before_field_html].present?
              options[:before_field_html].to_s
            end
          end
      end

      # Used when is optional
      def has_before_field_html?
        before_field_html.present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::BeforeFieldHtml)
