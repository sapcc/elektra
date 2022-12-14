module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups
    module IconHint
      # Name of the component method
      def icon_hint(wrapper_options = nil)
        @icon_hint ||=
          begin
            if options[:icon_hint].present?
              '<i class="fa fa-info-circle"></i>'.html_safe +
                options[:icon_hint].to_s.html_safe
            end
          end
      end

      # Used when is optional
      def has_icon_hint?
        icon_hint.present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::IconHint)
