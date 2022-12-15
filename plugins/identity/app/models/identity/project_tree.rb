module Identity
  # This class builds a tree based on given projects.
  class ProjectTree
    # Wrapper for project and project's children
    class Node
      attr_reader :project, :children

      def initialize(project = nil)
        @project = project
        @children = []
      end

      def name
        @project.nil? ? "ROOT" : @project.name
      end

      def parent_id
        @project.nil? ? nil : @project.parent_id
      end

      def root?
        @project.nil?
      end

      def method_missing(name, *args, &block)
        if @project.respond_to?(name)
          @project.send(name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @project.respond_to?(method_name, include_private)
      end
    end

    # root identifier
    ROOT = "root".freeze

    def initialize(projects = [])
      # create nodes hash where key is the project_id and value a Node object
      @nodes =
        projects.each_with_object(ROOT => Node.new) do |project, hash|
          hash[project.id] = Node.new(project)
        end
      # build tree by adding children to projects
      build_tree
    end

    def root
      @nodes[ROOT]
    end

    def to_hash
      @tree_hash ||= build_tree_hash(root)
    end

    def find_by_id(project_id)
      @nodes[project_id]
    end

    def print
      print_tree([root])
    end

    private

    def build_tree
      @nodes.each do |project_id, node|
        # ignore root node
        next if project_id == ROOT

        # if parent id is nil then add this node to root children
        if node.parent_id.nil?
          root.children << node
        else
          # parent id is not nil
          # Try to find a node by parent id or use root.
          # It can happen that the parent is not included in projects.
          # In this case we use the root node as parent.
          parent = find_by_id(node.parent_id) || root
          parent.children << node
        end
      end
    end

    def print_tree(nodes = [], prefix = "")
      nodes.each do |node|
        puts "#{prefix}#{node.name}\n"
        print_tree(node.children, "#{prefix}\t")
      end
    end

    def build_tree_hash(node, result = {})
      result["id"] = node.id if node.respond_to?(:id)
      result.merge!(node.attributes) if node.respond_to?(:attributes)

      if node.children.length.positive?
        result["nodes"] = []
        node.children.each do |subnode|
          result["nodes"] << build_tree_hash(subnode)
        end
      end
      result
    end
  end
end
