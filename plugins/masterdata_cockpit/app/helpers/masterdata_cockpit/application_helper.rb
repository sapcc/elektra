module MasterdataCockpit
  module ApplicationHelper
    def render_propagation_status(propagation_type)
      if propagation_type == 1
        content = "Propagation New"
        icon_name = "rocket"
      else
        content = "Propagation Always"
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
