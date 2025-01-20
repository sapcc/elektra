module MasterdataCockpit
  module ApplicationHelper
    # this is a helper method that renders a popover icon with a help hint
    # at the moment it is not used in the application
    def render_propagation_status_icon(propagation_type)
      if propagation_type == 1
        content = "Propagation-Type: Child blocks parent"
        icon_name = "lock"
      else
        content = "Propagation-Type: Parent always"
        icon_name = "exchange"
      end
  
      link_to(icon(icon_name), "#", class: "help-link", 
      data: {
        "content": content,
        "popover-type": "help-hint",
        "toggle": "popover"
      })
    end
  end
end
