require "spec_helper"

describe ResourceManagement::ApplicationHelper, type: :helper do
  describe "#data_age_as_string" do
    it "stringifies data ages" do
      # no granularity smaller than 1 minute
      expect(data_age_as_string(5.seconds.ago)).to eql("less than a minute ago")
      expect(data_age_as_string(50.seconds.ago)).to eql(
        "less than a minute ago",
      )

      # report exact minutes for <= 10 minutes
      expect(data_age_as_string(61.seconds.ago)).to eql("1 minute ago")
      expect(data_age_as_string(250.seconds.ago)).to eql("4 minutes ago")
      expect(data_age_as_string(596.seconds.ago)).to eql("10 minutes ago")

      # round to 5 minutes until full hour
      expect(data_age_as_string(19.minutes.ago)).to eql("20 minutes ago")
      expect(data_age_as_string(50.minutes.ago)).to eql("50 minutes ago")
      expect(data_age_as_string(57.minutes.ago)).to eql("55 minutes ago")
      expect(data_age_as_string(58.minutes.ago)).to eql("1 hour ago")
      expect(data_age_as_string(65.minutes.ago)).to eql("1 hour ago")

      # round to hours until half a day
      expect(data_age_as_string(650.minutes.ago)).to eql("11 hours ago")
      expect(data_age_as_string(700.minutes.ago)).to eql("12 hours ago")
      expect(data_age_as_string(800.minutes.ago)).to eql("1 day ago")

      # round to days after that, not weeks etc.
      expect(data_age_as_string(14.days.ago)).to eql("14 days ago")
      expect(data_age_as_string(50.days.ago)).to eql("50 days ago")
    end

    it "describes a set of timestamps with smallest and largest age" do
      timestamps = []
      10.times { timestamps.push(rand(5.seconds..30.minutes).ago) }
      # make sure that the value boundaries are included in the array
      timestamps[4] = 5.seconds.ago
      timestamps[8] = 30.minutes.ago
      expect(data_age_as_string(*timestamps)).to eql(
        "between less than a minute and 30 minutes ago",
      )
    end

    it "compresses common suffixes of age stringifications" do
      # e.g. it does not print "between 5 minutes and 3 minutes ago" here
      expect(data_age_as_string(5.minutes.ago, 3.minutes.ago)).to eql(
        "between 3 and 5 minutes ago",
      )
      expect(data_age_as_string(4.hours.ago, 11.hours.ago)).to eql(
        "between 4 and 11 hours ago",
      )
      expect(data_age_as_string(2.days.ago, 14.hours.ago)).to eql(
        "between 1 and 2 days ago",
      )
    end
  end
end
