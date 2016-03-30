module SimpleForm
  module Wrappers
    class Root < Many

      alias_method :old_html_classes, :html_classes  unless self.respond_to?(:old_html_classes)

      def html_classes(input, options)
        css = old_html_classes(input, options)
        css << ('has-help-hint') if input.has_help_hint?
        css.compact
      end

    end
  end
end