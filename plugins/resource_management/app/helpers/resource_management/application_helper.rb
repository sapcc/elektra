module ResourceManagement
  module ApplicationHelper
    include ResourceBarHelper

    def userfriendly_resource_name(resource)
      if resource.respond_to?(:name)
        resource_name = resource.name.to_s
      else
        resource_name = resource.to_s
      end

      # special case: for per-flavor instance quotas, do not attempt to
      # translate the flavor ID
      if resource_name =~ /^instances_/
        return resource_name.sub(/^instances_/, "")
      end

      # standard case: retrieve the resource name from the locale file
      return t("resource_management.#{resource_name}")
    end

    # Returns a pair of primary and secondary description of a resource (both
    # may be empty strings).
    def userfriendly_resource_description(resource)
      if resource.respond_to?(:name)
        resource_name = resource.name.to_s
      else
        resource_name = resource.to_s
      end

      # special case: for per-flavor instance quotas, there is a description of
      # the flavor in the "catalog:description" extra-spec
      if resource_name =~ /^instances_/
        flavor_name = resource_name.sub(/^instances_/, "")
        # map flavor name to ID
        flavor =
          (@flavor_cache ||= cloud_admin.compute.flavors).find do |f|
            f.name == flavor_name
          end
        return "", "" if flavor.nil?
        # retrieve extraspecs
        @flavor_metadata_cache ||= {}
        m =
          (
            @flavor_metadata_cache[
              flavor.id
            ] ||= cloud_admin.compute.find_flavor_metadata(flavor.id)
          )
        return "", "" if m.nil?

        mib = Core::DataType.new(:bytes, :mega)
        gib = Core::DataType.new(:bytes, :giga)

        puts ">>>>> FLAVOR: #{flavor.inspect}"
        primary = []
        primary << "#{flavor.vcpus} cores" if flavor.vcpus
        primary << "#{mib.format(flavor.ram.to_i)} RAM" if flavor.ram
        primary << "#{gib.format(flavor.disk.to_i)} disk" if flavor.disk
        secondary = m.attributes["catalog:description"] || ""
        return primary.join(", "), secondary
      end

      # standard case: most stuff does not have a description
      return "", ""
    end

    # Given a number of timestamps from ResourceManagement::Resource#updated_at,
    # calculates a string representation of the data age, such as
    #     "between 3 days and 1 hour ago"
    def data_age_as_string(*update_times)
      return "" if update_times.empty?
      max_age = age_to_string(update_times.min())
      min_age = age_to_string(update_times.max())

      if min_age == max_age
        return "#{min_age} ago"
      else
        # don't repeat unit if identical for both
        min_age_unit = min_age.split(/\s+/).last # NOTE: may be singular
        max_age_unit = max_age.split(/\s+/).last
        if min_age_unit == max_age_unit || "#{min_age_unit}s" == max_age_unit
          min_age = min_age.gsub(/(?<=\d)\s+\S+$/, "")
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
      return "1 minute" if minutes == 1
      return "#{minutes} minutes" if minutes < 10
      return "#{(seconds / 300).round * 5} minutes" if minutes < 58

      # case 3: less than half a day (round to 1 hour)
      hours = (seconds / 3600).round
      return "1 hour" if hours == 1
      return "#{hours} hours" if hours <= 12

      # case 4: count days
      days = (seconds / 86_400).round
      return days == 1 ? "1 day" : "#{days} days"
    end
  end
end
