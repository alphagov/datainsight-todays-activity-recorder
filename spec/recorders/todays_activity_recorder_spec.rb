require_relative "../spec_helper"
require_relative "../../lib/recorders/todays_activity"

describe "TodaysActivityRecorder" do
  before(:each) do
    @message = {
      :envelope => {
        :collector => "google_analytics.unique_visitors.hourly",
        :collected_at => DateTime.now.strftime
      },
      :payload => {
        :start_at => "2012-08-06 10:00:00",
        :end_at => "2012-08-06 11:00:00",
        :value => 500,
        :site => "govuk"
      }
    }
  end

  after(:each) do
    UniqueVisitors.destroy!
  end

  it "should store valid message" do
    Recorders::TodaysActivityRecorder.process_message(@message)

    UniqueVisitors.all.length.should == 1
    unique_visitors = UniqueVisitors.first
    unique_visitors.start_at.should == DateTime.parse("2012-08-06 10:00:00")
    unique_visitors.end_at.should == DateTime.parse("2012-08-06 11:00:00")
    unique_visitors.value.should == 500
    unique_visitors.site.should == "govuk"
    unique_visitors.collected_at.should be_within(3).of(DateTime.now)
    unique_visitors.created_at.should be_within(3).of(DateTime.now)
    unique_visitors.updated_at.should be_within(3).of(DateTime.now)
  end

  it "should update existing measurements" do
    Recorders::TodaysActivityRecorder.process_message(@message)
    @message[:payload][:value] = 900
    Recorders::TodaysActivityRecorder.process_message(@message)
    UniqueVisitors.all.length.should == 1
    UniqueVisitors.first.value.should == 900
  end
end