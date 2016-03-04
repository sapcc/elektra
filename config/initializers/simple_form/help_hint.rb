module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups
    module HelpHint
      # Name of the component method
      def help_hint(wrapper_options = nil)
        @help_hint ||= begin
          if options[:help_hint].present?
            '<div class="col-xs-1 col-sm-1 help-hint">' \
              '<a data-container="#popover_container" data-content="' + options[:help_hint].to_s + '" data-placement="top" data-popover-type="help-hint" data-toggle="popover" href="#" role="button" >' \
                '<span class="fa-stack fa-lg">' \
                  '<i class="fa fa-square fa-stack-2x"></i>' \
                  '<i class="fa fa-info fa-inverse fa-stack-1x"></i>' \
                '</span>' \
              '</a>' \
            '</div>'
          end
        end
      end

      # Used when is optional
      def has_help_hint?
        help_hint.present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::HelpHint)