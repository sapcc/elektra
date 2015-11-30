module ResourceManagement
  module ApplicationHelper

    def list_areas_with_enabled_services
      services = ResourceManagement::Resource::KNOWN_SERVICES
      services.select { |srv| srv[:enabled] }.map { |srv| srv[:area] }.uniq
    end

    # Given a number of timestamps from ResourceManagement::Resource#updated_at,
    # calculates a string representation of the data age, such as
    #     "between 3 days and 1 hour ago"
    def data_age_as_string(*update_times)
      max_age = age_to_string(update_times.min())
      min_age = age_to_string(update_times.max())

      if min_age == max_age
        return "#{min_age} ago"
      else
        # don't repeat unit if identical for both
        min_age_unit = min_age.split(/\s+/).last # NOTE: may be singular
        max_age_unit = max_age.split(/\s+/).last
        if min_age_unit == max_age_unit || "#{min_age_unit}s" == max_age_unit
          min_age = min_age.gsub(/(?<=\d)\s+\S+$/, '')
        end
        return "between #{min_age} and #{max_age} ago"
      end
    end

    private

    def age_to_string(time)
      # case 1: less than a minute
      seconds = Time.now - time
      return "less than a minute" if seconds < 60

      # case 2: less than an hour (round to 5 minutes if > 10 minutes)
      minutes = (seconds / 60).round
      return "1 minute"                           if minutes == 1
      return "#{minutes} minutes"                 if minutes < 10
      return "#{(seconds/300).round * 5} minutes" if minutes < 58

      # case 3: less than half a day (round to 1 hour)
      hours = (seconds / 3600).round
      return "1 hour"         if hours ==  1
      return "#{hours} hours" if hours <= 12

      # case 4: count days
      days = (seconds / 86400).round
      return days == 1 ? "1 day" : "#{days} days"
    end

  end
end
