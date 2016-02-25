module Automation
  module ApplicationHelper

    def flash_box(key, value)
      haml_tag :p, {class: "alert alert-#{key.to_s}", role: "alert"} do
        haml_concat value.to_s
      end
    end

    def job_history_entry(status)
      case status
        when 'queued'
          haml_tag :i, {class: "fa fa-square job_success", data: {popover_type: 'job-history'}}
        when 'executing'
          haml_tag :i, {class: "fa fa-spinner fa-spin", data: {popover_type: 'job-history'}}
        when 'failed'
          haml_tag :i, {class: "fa fa-square job_failed", data: {popover_type: 'job-history'}}
        when 'complete'
          haml_tag :i, {class: "fa fa-square job_success", data: {popover_type: 'job-history'}}
      end
    end

    def job_status(status)
      case status
        when 'failed'
          haml_tag :span, {class: "job_failed"} do
            haml_concat status.to_s
          end
        else
          haml_tag :span do
            haml_concat status.to_s
          end
      end
    end

  end
end
