# frozen_string_literal: true

module SharedFilesystemStorage
  module CloudAdmin
    module PoolsHelper
      def format_percentage(absolute_value, percentage_value)
        content_tag(:span, title: "#{percentage_value}%") { absolute_value }
      end
    end
  end
end
