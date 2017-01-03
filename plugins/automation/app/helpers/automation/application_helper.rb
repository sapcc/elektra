module Automation
  module ApplicationHelper

def grouped_chef_versions
			result = []
			major_versions = [""]
			major_versions.concat ::Automation::AvailableChefVersions.get.map {|version| version[/^\d+/]}.uniq
			result << ["General version", major_versions]
			result << ["Specific Version", ::Automation::AvailableChefVersions.get]
			result
		end

    def flash_box(key, value)
      haml_tag :p, {class: "alert alert-#{key.to_s}", role: "alert"} do
        haml_concat value.to_s
      end
    end

    def date_humanize(date)
      unless date.nil?
        " #{date}".to_time(:local).strftime('%Y-%m-%d %H:%M:%S %Z')
      end
    end

    def form_horizontal_static_input(label, value)
      haml_tag :div, {class: "form-group"} do
        haml_tag :label, {class: "col-sm-4 control-label"} do
          haml_concat label
        end
        haml_tag :div, {class: "col-sm-8"} do
          haml_tag :div, {class: "form-control-static"} do
            haml_concat html_escape(value)
          end
        end
      end
    end

    def form_horizontal_json_editor(label, value)
      haml_tag :div, {class: "form-group"} do
        haml_tag :label, {class: "col-sm-4 control-label"} do
          haml_concat label
        end
        haml_tag :div, {class: "col-sm-8"} do
          haml_tag :div, {id: "jsoneditor", data:{mode:"view", content: value}}
        end
      end
    end

    def form_horizontal_static_hash(label, data)
      haml_tag :div, {class: "form-group"} do
        haml_tag :label, {class: "col-sm-4 control-label"} do
          haml_concat label
        end
        haml_tag :div, {class: "col-sm-8"} do

          if !data.blank?
            haml_tag :div, {class: "form-control-static"} do
              form_static_hash_value(data)
            end
          end

        end
      end
    end

    def form_static_hash_value(data)
      unless data.blank?
        haml_tag :div, {class: "static-tags clearfix"} do
          data.split(',').each do |element|
            elements_array = element.split(/\:|\=/)
            if elements_array.count == 2
              haml_tag :div, {class: "tag"} do
                haml_tag :div, {class: "key"} do
                  haml_concat elements_array[0]
                end
                haml_tag :div, {class: "value"} do
                  haml_concat elements_array[1]
                end
              end
            end
          end
        end
      end
    end

    def form_horizontal_static_array(label, data)
      haml_tag :div, {class: "form-group"} do
        haml_tag :label, {class: "col-sm-4 control-label"} do
          haml_concat label
        end
        haml_tag :div, {class: "col-sm-8"} do

          if !data.blank?
            haml_tag :div, {class: "form-control-static"} do
              haml_tag :div, {class: "static-tags clearfix"} do

                data.split(',').each do |value|
                  haml_tag :div, {class: "tag"} do
                    haml_tag :div, {class: "value"} do
                      haml_concat html_escape(value)
                    end
                  end
                end

              end
            end
          end

        end
      end
    end

    #
    # Nodes
    #

    def node_form_inline_tags(data)
      if data.blank?
        haml_concat 'No tags available'
      else
        form_static_hash_value(data)
      end
    end

    def node_table_tags(data)
      unless data.blank?
        haml_tag :div, {class: "static-tags clearfix"} do
          data.each do |key, value|
            haml_tag :div, {class: "tag"} do
              haml_tag :div, {class: "key"} do
                haml_concat key
              end
              haml_tag :div, {class: "value"} do
                haml_concat value
              end
            end
          end
        end
      end
    end

    def compute_ips(addresses)
      unless addresses.nil?
        addresses.each do |network_name, ip_values|
          if ip_values and ip_values.length>0
            haml_tag :div, {class: "list-group borderless"} do
              ip_values.each do |values|
                haml_tag :p, {class: "list-group-item-text"} do
                  if values["OS-EXT-IPS:type"]=='floating'
                    haml_tag :i, {class: "fa fa-globe fa-fw"}
                  elsif values["OS-EXT-IPS:type"]=='fixed'
                    haml_tag :i, {class: "fa fa-desktop fa-fw"}
                  end
                  haml_concat values["addr"]
                  haml_tag :span, {class: "info-text"} do
                    haml_concat values["OS-EXT-IPS:type"]
                  end
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
          haml_tag :i, {class: "fa fa-square state_success", data: {popover_type: 'job-history'}}
        when ::Automation::State::Job::EXECUTING
          haml_tag :i, {class: "fa fa-spinner fa-spin", data: {popover_type: 'job-history'}}
        when ::Automation::State::Job::FAILED
          haml_tag :i, {class: "fa fa-square state_failed", data: {popover_type: 'job-history'}}
        when ::Automation::State::Job::COMPLETED
          haml_tag :i, {class: "fa fa-square state_success", data: {popover_type: 'job-history'}}
      end
    end

    def job_state(status)
      case status
        when State::Job::FAILED
          haml_tag :span, {class: "state_failed"} do
            haml_concat status.to_s
          end
        else
          haml_tag :span do
            haml_concat status.to_s
          end
      end
    end

    #
    # Automations
    #

    def selected_automation_type(type)
      if type.blank?
        return 'chef'
      else
        type.downcase
      end
    end

    def hide_chef_automation(type)
      if type.blank?
        return false
      else
        if type.downcase == 'chef'
          return false
        end
      end
      return true
    end

    def hide_script_automation(type)
      if type.blank?
        return true
      else
        if type.downcase == 'script'
          return false
        end
      end
      return true
    end

    #
    # Runs
    #

    def run_icon_state(state)
      case state
        when ::Automation::State::Run::PREPARING
          haml_tag :i, {class: "fa fa-square state_success", data: {popover_type: 'job-history'}}
        when ::Automation::State::Run::EXECUTING
          haml_tag :i, {class: "fa fa-spinner fa-spin", data: {popover_type: 'job-history'}}
        when ::Automation::State::Run::FAILED
          haml_tag :i, {class: "fa fa-square state_failed", data: {popover_type: 'job-history'}}
        when ::Automation::State::Run::COMPLETED
          haml_tag :i, {class: "fa fa-square state_success", data: {popover_type: 'job-history'}}
      end
    end

    def run_state(state, state_string)
      case state
        when State::Run::FAILED
          haml_tag :span, {class: "state_failed"} do
            haml_concat state_string
          end
        else
          haml_tag :span do
            haml_concat state_string
          end
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
