module Monitoring
  module ApplicationHelper

    def show_severity(severity)
      styles = {
        'LOW'      => 'text-info',
        'MEDIUM'   => 'text-warning',
        'HIGH'     => 'text-danger',
        'CRITICAL' => 'text-danger',
      }
      content_tag(:span, severity.capitalize, class: styles.fetch(severity, ''))
    end

    def show_state(state)
      styles = {
        'OK'           => 'text-success',
        'UNDETERMINED' => 'text-warning',
        'ALARM'        => 'text-danger',
      }
      content_tag(:span, state.capitalize, class: styles.fetch(state, ''))
    end

    def badge_state(state,value)
      styles = {
        'OK'           => 'alert-success',
        'UNDETERMINED' => 'alert-warning',
        'ALARM'        => 'alert-danger',
      }
      content_tag(:span, value, class: "badge #{styles.fetch(state, '')}")
    end
    
    def notification_method_type(type)
      if type == "EMAIL"
        return content_tag(:span, icon('envelope-o'), style: "cursor:help", title: 'notification by email' )
      elsif type == "WEBHOOK"
        return content_tag(:span, icon('globe'), style: "cursor:help", title: 'notification by webhook' )
      elsif type == "SLACK"
        return content_tag(:span, icon('slack'), style: "cursor:help", title: 'notification by slack' )
      else
        return content_tag(:strong, '?')
      end
    end

  end
end
