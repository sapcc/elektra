module Resources
  module ApplicationHelper
    def show_v2?
      current_region.start_with?("qa-")
    end
  end
end
