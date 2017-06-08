module Loadbalancing
  module ApplicationHelper

    def name_or_id(name, id)
      return name unless name.blank?
      return truncate(id, length: 10)
    end

  end
end
