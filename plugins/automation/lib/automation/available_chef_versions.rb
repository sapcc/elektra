module Automation
  class AvailableChefVersions
    def self.get
      @versions ||=
        begin
          ver =
            JSON.parse File.read(
                         File.join(
                           ::Automation::Engine.root,
                           "config/chef_versions.json",
                         ),
                       )
          ubuntu =
            Set.new(ver["ubuntu"].try(:[], "14.04").try(:[], "x86_64")) |
              Set.new(ver["ubuntu"].try(:[], "16.04").try(:[], "x86_64"))
          el =
            Set.new(ver["el"].try(:[], "6").try(:[], "x86_64")) |
              Set.new(ver["el"].try(:[], "7").try(:[], "x86_64"))
          windows =
            Set.new(ver["windows"].try(:[], "2008r2").try(:[], "i386")) |
              Set.new(ver["windows"].try(:[], "2008r2").try(:[], "x86_64"))
          (ubuntu & el & windows)
            .map { |v| Gem::Version.new(v) }
            .reject { |v| v.prerelease? || v >= Gem::Version.new("15") }
            .sort
            .map(&:to_s)
            .reverse
        end
    end
  end
end
