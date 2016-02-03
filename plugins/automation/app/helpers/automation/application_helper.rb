module Automation
  module ApplicationHelper

    def flash_box(key, value)
      haml_tag :p, {class: "alert alert-#{key}", role: "alert"} do
        value
      end
    end

  end
end
