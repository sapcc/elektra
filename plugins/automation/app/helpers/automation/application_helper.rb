module Automation
  module ApplicationHelper

    def flash_box(key, value)
      haml_tag :p, {class: "alert alert-#{key.to_s}", role: "alert"} do
        haml_concat value.to_s
      end
    end

  end
end
