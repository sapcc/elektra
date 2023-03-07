module Inquiry
  module InquiriesHelper
    def get_allowed_actions(inquiry)
      aasm_allowed_states = inquiry.states_allowed(current_user)

      callbacks = HashWithIndifferentAccess.new inquiry.callbacks
      actions = []
      aasm_allowed_states.each do |state|
        if callback = callbacks[state[:state]]
          action = callback["action"]
          modal = false
          if action.include?("?overlay=")
            modal = true
            action = action.partition("?overlay=").last
            action += "?inquiry_id=#{inquiry.id}"
          elsif action.include?("?")
            action += "&inquiry_id=#{inquiry.id}"
          else
            action += "?inquiry_id=#{inquiry.id}"
          end
          action += "&state=#{state[:name]}"
          link =
            link_to state[:events].first[:name], action, data: { modal: modal }

          actions << { name: state[:state].to_s, action: action, link: link }
        else
          action =
            plugin("inquiry").edit_inquiry_path(
              id: inquiry.id,
              new_state: state[:state].to_s,
            )
          link =
            link_to state[:events].first[:name],
                    plugin("inquiry").edit_inquiry_path(
                      id: inquiry.id,
                      state: state[:state].to_s,
                    ),
                    data: {
                      modal: true,
                    }
          actions << { name: state[:name], action: action, link: link }
        end
      end
      return actions
    end

    # This method creates a div with data needed attributes. The content is loaded via ajax by PollingService
    def remote_inquiries(options = {})
      container_id = options[:container_id]

      content_tag(:div, id: container_id) do
        content_tag(
          :div,
          "",
          data: {
            update_path:
              plugin("inquiry").inquiries_path(
                {
                  container_id: container_id,
                  per_page:
                    (options[:per_page] || Inquiry::Inquiry.default_per_page),
                  filter: (options[:filter] || {}),
                  partial: true,
                },
              ),
            update_immediately: true,
          },
        )
      end
    end

    def render_errors(inquiry)
    end

    def render_requestor_name(requestor)
      unless requestor.full_name.blank?
        "#{requestor.full_name} (#{requestor.name})"
      else
        requestor.name
      end
    end
  end
end
