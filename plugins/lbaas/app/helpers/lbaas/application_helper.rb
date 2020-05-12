module Lbaas

  ENTRIES_PER_PAGE = 20

  module ApplicationHelper

    def name_or_id(name, id, length=36)
      return truncate(name, length: length) unless name.blank?
      return truncate(id, length: length)
    end

    def description(desc, length=40)
      return truncate(desc, length: length)
    end

  end
end
