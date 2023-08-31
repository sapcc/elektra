module KeyManager
  module ApplicationHelper
    def date_humanize(date)
      unless date.nil?
        " #{date}".to_time(:local).strftime("%Y-%m-%d %H:%M:%S %Z")
      end
    end

    def secret_status(status)
      state_class = "state_success"
      if status != ::KeyManager::Secret::Status::ACTIVE
        state_class = "state_failed"
      end

      content_tag :span do
        content_tag :i,status.capitalize,
                {
                  class: "fa fa-square #{state_class}",
                  data: {
                    popover_type: "job-history",
                  },
                }
      end
    end

    def secret_content_types(data)
      unless data.blank?
        content_tag :div, { class: "static-tags clearfix" } do
          data.each do |key, value|
            content_tag :div, { class: "tag" } do
              content_tag :div, key, { class: "key" } 
              content_tag :div, value, { class: "value" }
            end
          end
        end
      end
    end
  end
end
