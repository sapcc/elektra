module ObjectStorage
  module ApplicationHelper

    def make_breadcrumb(container_name, path='')
      # empty path?
      return container_name if path.gsub('/', '') == ''
      # first breadcrumb element is container name, linking to its root directory
      result = link_to(container_name, plugin('object_storage').list_objects_path(container_name))

      # make one crumb per path element
      crumbs = []
      elements = path.split('/').delete_if { |e| e.blank? }
      last_crumb = elements.pop
      elements.each_with_index do |name,idx|
        link = plugin('object_storage').list_objects_path(container_name, path: elements[0..idx].join('/'))
        crumbs << link_to(name, link)
      end
      crumbs << last_crumb

      return result + " > " + crumbs.join('/').html_safe
    end

    def format_bytes(value_in_bytes)
      content_tag(:span, title: "#{value_in_bytes} bytes") { Core::DataType.new(:bytes).format(value_in_bytes) }
    end

    # Produces a human-readable representation of the given DateTime which is
    # assumed to be in the past.
    def format_mtime(datetime)
      now = DateTime.now
      # the minus operator returns the difference in days; convert to seconds
      diff_in_seconds = ((now - datetime) * 24 * 60 * 60).to_i

      if diff_in_seconds < 0
        # please check your NTP client :)
        text = 'soon'
      elsif diff_in_seconds < 60
        text = 'just now'
      elsif diff_in_seconds < 60 * 60
        diff_in_minutes = (diff_in_seconds / 60).to_i
        text = diff_in_minutes == 1 ? '1 minute ago' : "#{diff_in_minutes} minutes ago"
      elsif diff_in_seconds < 60 * 60 * 24
        diff_in_hours = (diff_in_seconds / 60 / 60).to_i
        text = diff_in_hours == 1 ? '1 hour ago' : "#{diff_in_hours} hours ago"
      else
        # count actual calendar days
        diff_in_full_days = (now.to_date - datetime.to_date).to_i
        text = diff_in_full_days == 1 ? 'yesterday' : "#{diff_in_full_days} days ago"
      end

      # show exact datetime in tooltip (like Github does)
      return content_tag(:span, title: datetime.strftime("%a %F %T %:z")) { text }
    end

  end
end
