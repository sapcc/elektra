module Lookup
  module ApplicationHelper

    def render_project_hierarchy(project)
      capture_haml do
        haml_tag :div do
          project[:parents].each do |parent|
            haml_concat parent[:name]
            haml_concat " / "
          end
          haml_concat project[:name]
        end
        haml_tag :div do
          haml_tag :span, class: 'info-text' do
            haml_concat project[:id]
          end
        end
      end
    end

  end
end
