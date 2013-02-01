require_relative "../spec_helper"
require_relative "../../lib/date_extension"

def hourly_message(data = {})
  default_message = {
    envelope: {
      collected_at: "2012-08-07T12:15:35",
      collector: "Google Analytics",
      _routing_key: "google_analytics.visitors.hourly"
    },
    payload: {
      start_at: "2012-08-06T00:00:00+00:00",
      end_at: "2012-08-06T01:00:00+00:00",
      value: {
        site: "govuk",
        visitors: 12345
      }
    }
  }

  default_message[:payload][:value].merge! data

  return default_message
end


describe HourlyUniqueVisitors do
  before(:each) do
    @two_hours_ago = DateTime.new(2012, 8, 16, 9, 50, 0)
    @now = DateTime.new(2012, 8, 16, 11, 50, 0)
    @yesterday = (@two_hours_ago - 1).to_date

    HourlyUniqueVisitors.destroy!
  end

  after(:each) do
    HourlyUniqueVisitors.destroy!
  end

  describe "update from message" do
    it "should insert a new record" do
      HourlyUniqueVisitors.update_from_message(hourly_message)

      visitors = HourlyUniqueVisitors.all

      visitors.should have(1).item

      visitors.first.collected_at.should == DateTime.new(2012, 8, 7, 12, 15, 35)
      visitors.first.source.should == "Google Analytics"
      visitors.first.start_at.should == DateTime.new(2012, 8, 6)
      visitors.first.end_at.should == DateTime.new(2012, 8, 6, 1)
      visitors.first.value.should == 12345
    end

    it "should update an existing record" do
      HourlyUniqueVisitors.update_from_message(hourly_message(visitors: 100))
      HourlyUniqueVisitors.update_from_message(hourly_message(visitors: 200))

      visitors = HourlyUniqueVisitors.all

      visitors.should have(1).item

      visitors.first.collected_at.should == DateTime.new(2012, 8, 7, 12, 15, 35)
      visitors.first.source.should == "Google Analytics"
      visitors.first.start_at.should == DateTime.new(2012, 8, 6)
      visitors.first.end_at.should == DateTime.new(2012, 8, 6, 1)
      visitors.first.value.should == 200
    end
  end
  describe "hour length validation" do
    it "should be valid if period is one hour" do
      unique_visitors = FactoryGirl.build(:hourly_unique_visitors,
                                          :start_at => DateTime.parse("2012-08-19T01:00:00+00:00"),
                                          :end_at => DateTime.parse("2012-08-19T02:00:00+00:00"))

      unique_visitors.should be_valid
    end

    it "should not be valid if period is bigger than one hour" do
      unique_visitors = FactoryGirl.build(:hourly_unique_visitors,
                                          :start_at => DateTime.parse("2012-08-19T01:00:00+00:00"),
                                          :end_at => DateTime.parse("2012-08-19T02:12:00+00:00"))

      unique_visitors.should_not be_valid
    end

    it "should not be valid if period is smaller than one hour" do
      unique_visitors = FactoryGirl.build(:hourly_unique_visitors,
                                          :start_at => DateTime.parse("2012-08-19T01:00:00+00:00"),
                                          :end_at => DateTime.parse("2012-08-19T01:59:00+00:00"))

      unique_visitors.should_not be_valid
    end

    it "should always be referencing a full hour" do
      unique_visitors = FactoryGirl.build(:hourly_unique_visitors,
                                          :start_at => DateTime.parse("2012-08-19T01:01:00+00:00"),
                                          :end_at => DateTime.parse("2012-08-19T02:01:00+00:00"))

      unique_visitors.should_not be_valid
    end
  end

  describe "field validation" do
    it "should be invalid if value is null" do
      unique_visitors = FactoryGirl.build(:hourly_unique_visitors, :value => nil)

      unique_visitors.should_not be_valid
    end

    it "should be invalid if value is negative" do
      unique_visitors = FactoryGirl.build(:hourly_unique_visitors, :value => -1)

      unique_visitors.should_not be_valid
    end

    it "should be valid if value is zero" do
      unique_visitors = FactoryGirl.build(:hourly_unique_visitors, :value => 0)

      unique_visitors.should be_valid
    end

    it "should have a non-null start_at" do
      unique_visitors = FactoryGirl.build(:hourly_unique_visitors, :start_at => nil)

      unique_visitors.should_not be_valid
    end

    it "should have a non-null end_at" do
      unique_visitors = FactoryGirl.build(:hourly_unique_visitors, :end_at => nil)

      unique_visitors.should_not be_valid
    end

    it "should have a non-null collected_at" do
      unique_visitors = FactoryGirl.build(:hourly_unique_visitors, :collected_at => nil)

      unique_visitors.should_not be_valid
    end
  end

  describe "last collected at" do
    it "should return the most recent collected at" do
      last_date = DateTime.new(2012, 2, 3, 4, 5, 6)
      first_date = DateTime.new(2011, 2, 3, 4, 5, 6)
      FactoryGirl.create(:hourly_unique_visitors, collected_at: last_date)
      FactoryGirl.create(:hourly_unique_visitors, collected_at: first_date)

      HourlyUniqueVisitors.last_collected_at.should == last_date
    end

    it "should default to UTC 1970-01-01" do
      HourlyUniqueVisitors.last_collected_at.should == DateTime.parse("1970-01-01T00:00:00+00:00")
    end
  end

  describe "data collection" do
    before(:each) do
      add_measurements((@now - 40).to_midnight, @now + 1) do |params|
        params[:collected_at] = @two_hours_ago
        params[:value] = params[:end_at] < @now ? 500 : 0
      end
    end

    describe "yesterdays visitors" do
      it "should return yesterdays visitors" do
        activity = HourlyUniqueVisitors.visitors_yesterday_by_hour(@two_hours_ago)
        activity.should have(24).items
        activity.should == [500] * 24
      end
    end

    describe "weekly average" do
      HOURS_IN_A_WEEK = 7 * 24

      def d(time_string)
        return DateTime.parse(time_string)
      end

      before(:each) {
        HourlyUniqueVisitors.destroy
      }

      it "should return *a* record within the requested time period" do
        FactoryGirl.create(:hourly_unique_visitors,
                           start_at: d("2012-12-12 00:00:00"),
                           end_at: d("2012-12-12 01:00:00"))

        records = HourlyUniqueVisitors.period(d("2012-12-11 00:00:00"), d("2012-12-13 00:00:00"))

        records.should have(1).record
        records.first.start_at.should == d("2012-12-12 00:00:00")
        records.first.end_at.should == d("2012-12-12 01:00:00")
      end

      it "should return *all* records within the requested time period" do
        add_measurements(d("2012-12-12 00:00:00"),d("2012-12-14 00:00:00"))

        records = HourlyUniqueVisitors.period(d("2012-12-13 00:00:00"), d("2012-12-13 12:00:00"))

        records.should have(12).records
      end

      it "should not return records outside of the requested time period" do
        FactoryGirl.create(:hourly_unique_visitors,
                           start_at: d("2012-12-15 00:00:00"),
                           end_at: d("2012-12-15 01:00:00"))

        records = HourlyUniqueVisitors.period(d("2012-12-11 00:00:00"), d("2012-12-13 00:00:00"))

        records.should be_empty
      end

      it "should return an empty array if there are no matching records" do
        records = HourlyUniqueVisitors.period(d("2012-12-11 00:00:00"), d("2012-12-13 00:00:00"))

        records.should be_empty
      end

    end

  end

end