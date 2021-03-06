require_relative "spec_helper"
require_relative "../lib/recorder"

describe "recorder" do
  a_minute = Rational(1, 24 * 60)
  yesterday = DateTime.now - 1

  before(:each) do
    @message = {
      :envelope => {
        :collector => "Google Analytics",
        :collected_at => yesterday.strftime,
        :_routing_key => "google_analytics.visitors.hourly"
      },
      :payload => {
        :start_at => "2012-08-06T10:00:00+00:00",
        :end_at => "2012-08-06T11:00:00+00:00",
        :value => {
          :visitors => 500,
          :site => "govuk"
        }
      }
    }
    @recorder = Recorder.new
  end

  before(:each) do
    HourlyUniqueVisitors.destroy!
    DailyUniqueVisitors.destroy!
  end

  after(:each) do
    HourlyUniqueVisitors.destroy!
    DailyUniqueVisitors.destroy!
  end

  it "should store valid message" do
    @recorder.update_message(@message)

    HourlyUniqueVisitors.all.length.should == 1
    unique_visitors = HourlyUniqueVisitors.first
    unique_visitors.start_at.should == DateTime.new(2012, 8, 6, 10, 0, 0, DateTime.now.zone)
    unique_visitors.end_at.should == DateTime.new(2012, 8, 6, 11, 0, 0, DateTime.now.zone)
    unique_visitors.value.should == 500
    unique_visitors.collected_at.should be_within(a_minute).of(yesterday)
  end

  it "should store valid message" do
    @message[:envelope][:_routing_key] = "google_analytics.visitors.daily"
    @message[:payload][:start_at] = Date.new(2012, 10, 1).to_datetime.strftime
    @message[:payload][:end_at] = Date.new(2012, 10, 2).to_datetime.strftime

    @recorder.update_message(@message)

    DailyUniqueVisitors.all.length.should == 1
    unique_visitors = DailyUniqueVisitors.first
    unique_visitors.start_at.should == DateTime.new(2012, 10, 1, 0, 0, 0, DateTime.now.zone)
    unique_visitors.end_at.should == DateTime.new(2012, 10, 2, 0, 0, 0, DateTime.now.zone)
    unique_visitors.value.should == 500
    unique_visitors.collected_at.should be_within(a_minute).of(yesterday)
  end

  it "should update existing measurements" do
    @recorder.update_message(@message)
    @message[:payload][:value][:visitors] = 900
    @message[:envelope][:collected_at] = DateTime.now.strftime
    @recorder.update_message(@message)
    HourlyUniqueVisitors.all.length.should == 1

    visitors = HourlyUniqueVisitors.first
    visitors.value.should == 900
    visitors.collected_at.should be_within(a_minute).of(DateTime.now)
  end

  describe "validation" do
    it "should raise an error if model is invalid" do
      @message[:payload][:start_at] = "2012-08-06T10:30+00:00"

      lambda do
        @recorder.update_message(@message)
      end.should raise_error
    end

    it "should fail if value is not present" do
      @message[:payload].delete(:value)

      lambda do
        @recorder.update_message(@message)
      end.should raise_error
    end

    it "should fail if value cannot be parsed as a integer" do
      @message[:payload][:value] = "invalid"

      lambda do
        @recorder.update_message(@message)
      end.should raise_error
    end

    it "should not allow nil as a value" do
      @message[:payload][:value] = nil

      lambda do
        @recorder.update_message(@message)
      end.should raise_error
    end

    it "should raise an error if the routing key is not recognised" do
      @message[:envelope][:_routing_key] = "invalid"

      lambda do
        @recorder.update_message(@message)
      end.should raise_error
    end
  end
end
