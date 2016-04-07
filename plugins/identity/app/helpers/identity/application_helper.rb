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
  end
end