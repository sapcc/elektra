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

    def render_project_tree(nodes, options={})
      nodes = [nodes] unless nodes.is_a?(Array)
      haml_tag :ul, class: ("tree tree-expandable" unless options[:child_tree]) do
        nodes.each do |node|
          has_children = node.children.length > 0
          haml_tag :li, class: ("has-children" if has_children) do
            haml_tag :i, class: "node-icon"
            unless node.root?
              haml_tag :a, node.name, href: plugin('identity').project_path(project_id: node.friendly_id)
            end

            if has_children
              render_project_tree(node.children, child_tree: true)
            end
          end
        end
      end

    end


  end
end
