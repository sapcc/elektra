require 'spec_helper'
require 'active_support/core_ext/date_time/calculations'

describe ObjectStorage::ApplicationHelper, type: :helper do

  describe '#format_mtime' do
    def format_duration_as_mtime(duration)
      format_mtime(DateTime.now.ago(duration.to_i))
    end

    it "stringifies data ages" do
      # no granularity smaller than 1 minute
      expect(format_duration_as_mtime(5.seconds)).to   match(/just now/)
      expect(format_duration_as_mtime(50.seconds)).to  match(/just now/)

      # report minutes for < 1 hour
      expect(format_duration_as_mtime(61.seconds)).to  match(/1 minute ago/)
      expect(format_duration_as_mtime(250.seconds)).to match(/4 minutes ago/)
      expect(format_duration_as_mtime(596.seconds)).to match(/9 minutes ago/)
      expect(format_duration_as_mtime(19.minutes)).to  match(/19 minutes ago/)
      expect(format_duration_as_mtime(50.minutes)).to  match(/50 minutes ago/)
      expect(format_duration_as_mtime(57.minutes)).to  match(/57 minutes ago/)
      expect(format_duration_as_mtime(58.minutes)).to  match(/58 minutes ago/)

      # report hours for < 1 day
      expect(format_duration_as_mtime(65.minutes)).to  match(/1 hour ago/)
      expect(format_duration_as_mtime(650.minutes)).to match(/10 hours ago/)
      expect(format_duration_as_mtime(700.minutes)).to match(/11 hours ago/)
      expect(format_duration_as_mtime(800.minutes)).to match(/13 hours ago/)

      # round to days after that, not weeks etc.
      expect(format_duration_as_mtime(14.days)).to match(/14 days ago/)
      expect(format_duration_as_mtime(50.days)).to match(/50 days ago/)
    end
  end

end
