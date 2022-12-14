module Core
  class Formatter
    class << self
      # Given a DateTime instance, which is assumed to refer to some time in
      # the past, produce a human-readable represention for how long ago this
      # time was. To be used for creation and modification timestamps.
      def format_modification_time(mtime)
        # check for exact class (can't rely on duck-typing here since different
        # datetime classes behave subtly different; e.g. subtraction of
        # DateTime gives a diff in days, but subtraction of
        # ActiveSupport::TimeWithZone gives a diff in seconds)
        unless mtime.is_a?(DateTime)
          raise ArgumentError,
                "format_modification_time: expected argument of class DateTime, got #{mtime.class.to_s}"
        end

        now = DateTime.now
        # the minus operator returns the difference in days; convert to seconds
        diff_in_seconds = ((now - mtime) * 24 * 60 * 60).to_i

        if diff_in_seconds < 0
          # please check your NTP client :)
          text = "soon"
        elsif diff_in_seconds < 60
          text = "just now"
        elsif diff_in_seconds < 60 * 60
          diff_in_minutes = (diff_in_seconds / 60).to_i
          text =
            (
              if diff_in_minutes == 1
                "1 minute ago"
              else
                "#{diff_in_minutes} minutes ago"
              end
            )
        elsif diff_in_seconds < 60 * 60 * 24
          diff_in_hours = (diff_in_seconds / 60 / 60).to_i
          text =
            diff_in_hours == 1 ? "1 hour ago" : "#{diff_in_hours} hours ago"
        else
          # count actual calendar days
          diff_in_full_days = (now.to_date - mtime.to_date).to_i
          text =
            (
              if diff_in_full_days == 1
                "yesterday"
              else
                "#{diff_in_full_days} days ago"
              end
            )
        end

        # show exact mtime in tooltip (like Github does)
        return(
          ActionController::Base
            .helpers
            .content_tag(:span, title: mtime.strftime("%a %F %T %:z")) { text }
        )
      end
    end
  end
end
