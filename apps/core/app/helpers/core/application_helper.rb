module Core
  module ApplicationHelper
    # # for the case a url or path helper method from the main app is needed
    # def method_missing method, *args, &block
    #   p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    #   p method
    #   if (method.to_s.end_with?('_path') or method.to_s.end_with?('_url')) and core_app.respond_to?(method)
    #     core_app.send(method, *args)
    #   else
    #     super
    #   end
    # end
    
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

    def body_class
      css_class = controller.controller_name
      page_id = params[:id].split('/').last if params[:id]
      css_class = "#{css_class} #{page_id}" if css_class == "pages"
      css_class
    end

    def external_link_to(name, url)
      haml_tag :a, href: url do
        # haml_tag :span, class: "glyphicon glyphicon-share-alt"
        haml_tag :span, class: "fa fa-external-link"
        haml_concat name
      end
    end

  end
end