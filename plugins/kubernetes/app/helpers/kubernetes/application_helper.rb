module Kubernetes
  module ApplicationHelper
    def render_contact_for_beta_access(contact = {})
      if contact[:email]
        if contact[:name]
          link_to(contact[:name], "mailto:#{contact[:email]}")
        else
          link_to(contact[:email], "mailto:#{contact[:email]}")
        end
      elsif contact[:name]
        "#{contact[:name]}"
      else
        "us"
      end
    end
  end
end
