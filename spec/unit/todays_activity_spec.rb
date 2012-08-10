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
    add_measurements((now - 1).to_midnight, now + 1)

    activity = TodaysActivity.visitors_today
    activity.length.should == now.hour
    activity[0].start_at.hour.should == 0
    activity[-1].start_at.hour.should == now.hour - 1
  end

  it "should return yesterdays visitors" do
    now = DateTime.now
    add_measurements(DateTime.new(now.year, now.month, now.day) - 2, now)
    one_day_ago = (now-1)

    activity = TodaysActivity.visitors_yesterday
    activity.length.should == 24
    activity[0].start_at.should == one_day_ago.to_midnight
    activity[-1].start_at.should == one_day_ago.to_full_hour(23)
  end

  it "should return monthly average" do
    # add data points for the last 40 days
    now = DateTime.now
    add_measurements((now - 40).to_midnight, now + 1) do |date_time|
      day_number = (now - date_time).to_i
      case date_time.hour
        when 0
          500
        when 1
          day_number
        when 2
          day_number % 3 == 0 ? 10 : 0
        when 3
          day_number %3 != 0 ? 10 : 0
        else
          50
      end
    end


    averages = TodaysActivity.last_month_average
    averages.length.should === 24

    averages.first.should be_a(Hash)
    averages.last.should be_a(Hash)

    averages.first[:hour].should eql(0)
    averages.last[:hour].should eql(23)

    averages[0][:value].should eql(500)
    averages[1][:value].should eql(16)
    averages[2][:value].should eql(3)
    averages[3][:value].should eql(7)
    averages[4][:value].should eql(50)
  end
end
