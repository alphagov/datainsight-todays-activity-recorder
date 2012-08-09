require "date"

require_relative "../spec_helper"
require_relative "../../lib/todays_activity"

describe "TodaysActivity" do

  after(:each) do
    UniqueVisitors.destroy!
  end

  it "should return todays visitors" do
    # add data points for yesterday and today
    now = DateTime.now
    add_measurements(DateTime.new(now.year, now.month, now.day) - 1, now + 1)

    activity = TodaysActivity.visitors_today
    activity.length.should == now.hour
    activity[0].start_at.hour.should == 0
    activity[-1].start_at.hour.should == now.hour - 1
  end

  it "should return yesterdays visitors" do
    now = DateTime.now
    add_measurements(DateTime.new(now.year, now.month, now.day) - 2, now)

    activity = TodaysActivity.visitors_yesterday
    activity.length.should == 24
    activity[0].start_at.should == DateTime.new((now-1).year, (now-1).month, (now-1).day)
    activity[-1].start_at.should == DateTime.new((now-1).year, (now-1).month, (now-1).day, 23)
  end
end
