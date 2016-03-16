module Identity
module ApplicationHelper

    # transfer rubytree into json array for tree plugin
    def projects_tree
      tree = doit @user_domain_projects_tree
      return tree
      # example json strcture
      #return {"text":"abc","href":"#","nodes":[{"text":"torsten_staging","href":"#"},{"text":"D003258","href":"#"}]}

    end

    # recursive traversal of tree from root node
    def doit node
      if node.name != 'domain'
        topnode = {text: node.content.name,
                   href: plugin('identity').project_path(project_id:node.content.friendly_id),
                   tags: [node.children.count]}
      else
        topnode = {text: node.content.name}
      end

      childs = []
      node.children do |child|
        childs << doit(child)
      end
      unless childs.blank?
        topnode[:nodes] = []
        topnode[:nodes] = childs
      end
      return topnode
    end
end
end