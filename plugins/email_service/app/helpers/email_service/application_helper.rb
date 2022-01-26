module EmailService
  module ApplicationHelper

    def render_error_messages(errors=[])
      content_tag(:ul) do
        errors.each do |error|
          concat(content_tag(:li, "#{error[:name]}: - #{error[:message]}"))
        end
      end
    end

  end
end