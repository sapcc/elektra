module Monitoring
  module ApplicationHelper

    def show_severity(severity)
      styles = {
        'LOW'      => 'text-info',
        'MEDIUM'   => 'text-warning',
        'HIGH'     => 'text-danger',
        'CRITICAL' => 'text-danger',
      }
      return content_tag(:span, severity.capitalize, class: styles.fetch(severity, ''))
    end

    def show_state(state)
      styles = {
        'OK'           => 'text-success',
        'UNDETERMINED' => 'text-warning',
        'ALARM'        => 'text-danger',
      }
      return content_tag(:span, state.capitalize, class: styles.fetch(state, ''))
    end

    def badge_state(state,value)
      styles = {
        'OK'           => 'alert-success',
        'UNDETERMINED' => 'alert-warning',
        'ALARM'        => 'alert-danger',
      }
        content_tag(:span, value, class: "badge #{styles.fetch(state, '')}")
    end

    def badge_severity(severity,value)
      styles = {
        'LOW'      => 'alert-info',
        'MEDIUM'   => 'alert-warning',
        'HIGH'     => 'alert-danger',
        'CRITICAL' => 'alert-danger',
      }
      return content_tag(:span, value, class: "badge #{styles.fetch(severity, '')}" )
    end
  end
end
