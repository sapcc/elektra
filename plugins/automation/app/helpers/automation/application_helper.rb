module Automation
  module ApplicationHelper
    def grouped_chef_versions
      result = []
      major_versions = [""]
      major_versions.concat ::Automation::AvailableChefVersions
                              .get
                              .map { |version| version[/^\d+/] }
                              .uniq
      result << ["General version", major_versions]
      result << ["Specific Version", ::Automation::AvailableChefVersions.get]
      result
    end

    def flash_box(key, value)
      content_tag :p, html_escape(value), class: "alert alert-#{key}", role: "alert"
    end

    def date_humanize(date)
      unless date.nil?
        " #{date}".to_time(:local).strftime("%Y-%m-%d %H:%M:%S %Z")
      end
    end

    def form_horizontal_static_input(label, value)
      content_tag :div, class: "form-group" do
        concat (content_tag :label, label, class: "col-sm-4 control-label")
        concat (content_tag :div, class: "col-sm-8" do
          content_tag :div, html_escape(value), class: "form-control-static"
        end)
      end
    end

    def form_horizontal_json_editor(
      attribute_name,
      id,
      label,
      label_classes,
      content,
      help_text,
      on_change_update_field,
      object
    )
      has_error = false
      if !object.blank? && !object.errors.blank? &&
          !object.errors.messages.blank? &&
          !object.errors.messages[attribute_name.to_sym].blank?
        has_error = true
      end

      content_tag :div,
              class: "form-group #{has_error ? "has-error" : ""}",
              id: id do
        content_tag :label, label, class: "text col-sm-4 control-label #{label_classes}"
        
        content_tag :div, class: "col-sm-8" do
          content_tag :div, class: "input-wrapper" do
            content_tag :div,
                    id: "jsoneditor",
                    data: {
                      mode: "code",
                      content_id: content,
                      on_change_update_field: on_change_update_field,
                    }
          end
          unless help_text.blank?
            content_tag :p, class: "help-block" do
              concat content_tag :i, class: "fa fa-info-circle"
              concat help_text
            end
          end
          if has_error
            object.errors.messages[attribute_name.to_sym].each do |message|
              concat content_tag :span, message, class: "help-block" 
            end
          end
        end
      end
    end

    def form_horizontal_static_json_editor(label, value)
      content_tag :div, class: "form-group" do
        concat content_tag :label, label, class: "col-sm-4 control-label"
        concat (content_tag :div, class: "col-sm-8" do
          concat (content_tag :div, nil, id: "jsoneditor", data: { mode: "view", content: value })
        end)
      end
    end

    def form_horizontal_static_hash(label, data)
      content_tag :div, class: "form-group" do
        concat (content_tag :label, label, class: "col-sm-4 control-label")
        concat (content_tag :div, class: "col-sm-8" do
          unless data.blank?
            content_tag :div, form_static_hash_value(data), class: "form-control-static" 
          end
        end)
      end
    end

    def form_static_hash_value(data)
      unless data.blank?
        content_tag :div, class: "static-tags clearfix" do
          data
            .split(Helpers::TAG_SEPERATOR)
            .each do |element|
              elements_array = element.split(/\:|\=/)
              next unless elements_array.count == 2

              content_tag :div, class: "tag" do
                concat content_tag :div, elements_array[0], class: "key" 
                concat content_tag :div, elements_array[1], class: "value" 
              end
            end
        end
      end
    end

    def form_horizontal_static_array(label, data)
      content_tag :div, class: "form-group" do
        concat (content_tag :label, label, class: "col-sm-4 control-label")
        concat (content_tag :div, class: "col-sm-8" do
          unless data.blank?
            concat (content_tag :div, class: "form-control-static" do
              content_tag :div, class: "static-tags clearfix" do
                data
                  .split(Helpers::TAG_SEPERATOR)
                  .each do |value|
                    concat (content_tag :div, class: "tag" do
                      content_tag :div, html_escape(value), class: "value"
                    end)
                  end
              end
            end)
          end
        end)
      end
    end

    #
    # Nodes
    #

    def node_form_inline_tags(data)
      if data.blank?
        "No tags available"
      else
        form_static_hash_value(data)
      end
    end

    def node_table_tags(data)
      unless data.blank?
        content_tag :div, class: "static-tags clearfix" do
          data.each do |key, value|
            content_tag :div, class: "tag" do
              concat content_tag :div, key, class: "key"
              concat content_tag :div, value, class: "value" 
            end
          end
        end
      end
    end

    def compute_name_with_image_name(instance)
      name = instance.name
      unless instance.image_object.try(:name).blank?
        name += "(#{instance.image_object.try(:name)})"
      end
      name
    end

    def compute_ips(addresses)
      unless addresses.nil?
        addresses.each do |_network_name, ip_values|
          next unless ip_values && !ip_values.empty?

          content_tag :div, class: "list-group borderless" do
            ip_values.each do |values|
              next if values["addr"].blank?

              content_tag :p, class: "list-group-item-text" do
                if values["OS-EXT-IPS:type"] == "floating"
                  content_tag :i, class: "fa fa-globe fa-fw"
                elsif values["OS-EXT-IPS:type"] == "fixed"
                  content_tag :i, class: "fa fa-desktop fa-fw"
                end
                concat values["addr"]
                content_tag :span, class: "info-text" do
                  concat values["OS-EXT-IPS:type"]
                end
              end
            end
          end
        end
      end
    end

    #
    # Jobs
    #

    def job_history_entry(status)
      case status
      when ::Automation::State::Job::QUEUED
        content_tag :i,
                class: "fa fa-square state_success",
                data: {
                  popover_type: "job-history",
                }
      when ::Automation::State::Job::EXECUTING
        content_tag :i,
                class: "fa fa-spinner fa-spin",
                data: {
                  popover_type: "job-history",
                }
      when ::Automation::State::Job::FAILED
        content_tag :i,
                class: "fa fa-square state_failed",
                data: {
                  popover_type: "job-history",
                }
      when ::Automation::State::Job::COMPLETED
        content_tag :i,
                class: "fa fa-square state_success",
                data: {
                  popover_type: "job-history",
                }
      end
    end

    def job_icon_state(status)
      case status
      when ::Automation::State::Job::QUEUED
        content_tag :i, class: "fa fa-square state_success"
      when ::Automation::State::Job::EXECUTING
        content_tag :i, class: "fa fa-spinner fa-spin"
      when ::Automation::State::Job::FAILED
        content_tag :i, class: "fa fa-square state_failed"
      when ::Automation::State::Job::COMPLETED
        content_tag :i, class: "fa fa-square state_success"
      end
    end

    def job_state(status)
      case status
      when State::Job::FAILED
        content_tag :span, status.to_s.humanize, class: "state_failed"
      else
        content_tag :span, status.to_s.humanize
      end
    end

    #
    # Automations
    #

    def displayCheck(option)
      if option
        content_tag :i, class: "fa fa-check"
      else
        content_tag :i, class: "fa fa-times"
      end
    end

    def selected_automation_type(type)
      type.blank? ? "chef" : type.downcase
    end

    def hide_chef_automation(type)
      if type.blank?
        return false
      else
        return false if type.casecmp("chef").zero?
      end

      true
    end

    def hide_script_automation(type)
      if type.blank?
        return true
      else
        return false if type.casecmp("script").zero?
      end

      true
    end

    #
    # Runs
    #

    def run_icon_state(state)
      case state
      when ::Automation::State::Run::PREPARING
        content_tag :i, nil, class: "fa fa-square state_success"
      when ::Automation::State::Run::EXECUTING
        content_tag :i, nil, class: "fa fa-spinner fa-spin"
      when ::Automation::State::Run::FAILED
        content_tag :i, nil, class: "fa fa-square state_failed"
      when ::Automation::State::Run::COMPLETED
        content_tag :i, nil, class: "fa fa-square state_success"
      end
    end

    def run_state(state)
      case state
      when State::Run::FAILED
        content_tag :span,  state.to_s.humanize, class: "state_failed"
      else
        content_tag :span, state.to_s.humanize
      end
    end

    def run_polling?(state)
      if state == ::Automation::State::Run::FAILED || state == ::Automation::State::Run::COMPLETED
        false
      else
        true
      end
    end
  end
end
