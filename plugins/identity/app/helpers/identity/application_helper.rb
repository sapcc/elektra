module Identity
  module ApplicationHelper

    # creates a tree for projectview based on project_tree delivered by controller
    def project_tree(nodes, result=[])
      nodes = [nodes] unless nodes.is_a?(Array)
      nodes.collect do |node|
        attrs = {"text" => node.name}
        attrs["tags"] = [node.children.length] if node.children.length>0
        attrs["href"] = plugin('identity').project_path(project_id: node.friendly_id) unless node.root?
        attrs["nodes"] = project_tree(node.children) if node.children.length>0
        attrs
      end
    end

    # This helper renders a project tree as unordered list.
    # Important: to use the jQuery plugin 'searchable' the li elements have to have data attribute search-name -> data-search-name.
    def render_project_tree(nodes, options={})
      nodes = [nodes] unless nodes.is_a?(Array)
      html_options = options[:html] || {}
      html_options[:class] ||= ''
      html_options[:class] += " tree tree-expandable" unless options[:child_tree]
      item_html = options[:item_html] || {}

      content_tag :ul, html_options do
        nodes.each do |node|
          has_children = node.children.length > 0
          concat(content_tag(:li, {class: ("has-children" if has_children), data: {search_name: node.name}}) do
            concat(content_tag(:i, '', class: "node-icon"))

            unless node.root?
              concat link_to(node.name, plugin('identity').project_path(project_id: node.friendly_id))
            end

            if has_children
              concat render_project_tree(node.children, child_tree: true)
            end
          end)
        end
      end

    end


  end
end
