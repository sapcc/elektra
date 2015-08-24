module ApplicationHelper


  # ---------------------------------------------------------------------------------------------------
  # Favicon Helpers
  # ---------------------------------------------------------------------------------------------------

  def favicon_png
    capture_haml do
      haml_tag :link, rel: "icon", type: "image", href: image_path("favicon.png")
    end
  end

  def favicon_ico
    capture_haml do
      haml_tag :link, rel: "shortcut icon", type: "image/x-icon", href: image_path("favicon.ico")
    end
  end


  def apple_touch_icon
    capture_haml do
      haml_tag :link, rel: "apple-touch-icon", href: image_path("apple-touch-icon.png")
    end
  end


  # ---------------------------------------------------------------------------------------------------
  # Text Helpers
  # ---------------------------------------------------------------------------------------------------

  def processed_controller_name
    name = controller.controller_name
    return "Services" if name == "pages"

    name.humanize
  end

end
