module Identity
  module ProjectsHelper

    # This method loads remote projects via ajax into a new created div.
    def remote_projects(options={})
      container_id = SecureRandom.hex

      content_tag(:div, id: container_id) do
        content_tag(:div, '', data: {
          update_path: plugin('identity').projects_path({
            per_page: (options[:per_page] || 3),
            filter: (options[:filter] || {}),
            partial: true
          }),
          update_immediately: true
        })
      end

    end

    def role_label_long(role_name)
      t("roles.#{role_name}") + " (#{role_name})"
    end

    def callout_css_class(status)
      css_class = 'bs-callout-'
      css_class += if status==ProjectProfile::STATUS_DONE
        'success'
      elsif status==ProjectProfile::STATUS_SKIPED
        'warning'
      else
        'info'
      end
      css_class
    end

    def wizard_step(options={},&block)
      title = options[:title]
      description = options[:description]
      mandatory = options[:mandatory] || false
      status = options[:status]
      css_class = case status
      when ProjectProfile::STATUS_DONE then 'success'
      when ProjectProfile::STATUS_SKIPED then 'warning'
      else 'info'
      end
      action_button = block.call(:action_button)
      skip_button = block.call(:skip_button)

      byebug
      content_tag :div, class: "bs-callout bs-callout-emphasize bs-callout-#{css_class}" do
        content_tag :div, class: 'row' do
          concat(content_tag(:div, class: 'col-md-8') do
            concat content_tag(:h4, title)
            concat content_tag(:p, description)
          end)
          concat(content_tag(:div, class: 'col-md-4') do
            if status==ProjectProfile::STATUS_SKIPED
              concat(content_tag :span, 'skiped', class: 'pull-right')
              concat(action_button)
            elsif status==ProjectProfile::STATUS_DONE
              content_tag :i, '', class: 'fa fa-check fa-3x pull-right'
            else
              content_tag :p, action_button
              content_tag :p, skip_button
            end
          end)
        end
      end

    end

  end
end
