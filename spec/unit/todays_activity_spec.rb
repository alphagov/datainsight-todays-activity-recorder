require "date"

require_relative "../spec_helper"
require_relative "../../lib/todays_activity_model"

describe "TodaysActivityModel" do

  before(:each) do
    @two_hours_ago = DateTime.new(2012, 8, 16, 9, 50, 0)
    @now = DateTime.new(2012, 8, 16, 11, 50, 0)
    @yesterday = (@two_hours_ago - 1).to_date

    @todays_activity = TodaysActivityModel.new
  end

  before(:each) do
    HourlyUniqueVisitors.destroy!
  end

  after(:each) do
    HourlyUniqueVisitors.destroy!
  end

  describe "todays activity" do
    it "should assemble the result" do
      @todays_activity.stub(:live_at).and_return(@two_hours_ago)
      @todays_activity.stub(:visitors_yesterday_by_hour).and_return([100]*24)
      @todays_activity.stub(:last_week_average_by_hour).and_return([300]*24)

      activity = @todays_activity.todays_activity
      activity[:live_at].should == @two_hours_ago
      activity[:for_date].should == @yesterday
      activity[:data].should have(24).items
      activity[:data][0].should == {
        :hour_of_day => 0,
        :value => {
          :yesterday => 100,
          :last_week_average => 300
        }}
      activity[:data][4].should == {
        :hour_of_day => 4,
        :value => {
          :yesterday => 100,
          :last_week_average => 300
        }}
      activity[:data][7].should == {
        :hour_of_day => 7,
        :value => {
          :yesterday => 100,
          :last_week_average => 300
        }}
      activity[:data][23].should == {
        :hour_of_day => 23,
        :value => {
          :yesterday => 100,
          :last_week_average => 300
        }}
    end
  end


  describe("live at") do
    it "should return the most recent collected at" do
      last_date = DateTime.new(2012, 2, 3, 4, 5, 6)
      first_date = DateTime.new(2011, 2, 3, 4, 5, 6)
      FactoryGirl.create(:unique_visitors, collected_at: last_date)
      FactoryGirl.create(:unique_visitors, collected_at: first_date)

      @todays_activity.live_at.should == last_date
    end
  end

  describe "data selection" do

    before(:each) do
      add_measurements((@now - 40).to_midnight, @now + 1) do |params|
        params[:collected_at] = @two_hours_ago
        params[:value] = params[:end_at] < @now ? 500 : 0
      end
    end

    describe "yesterdays visitors" do

      it "should return yesterdays visitors" do

        activity = @todays_activity.visitors_yesterday_by_hour(@two_hours_ago)
        activity.should have(24).items
        activity.should == [500] * 24
      end
    end

    describe "weekly average" do
      it "should return weekly average" do
        @todays_activity.stub(:average).and_return(400)

        activity = @todays_activity.last_week_average_by_hour(@two_hours_ago)
        activity.should have(24).items
        activity.should == [400] * 24
      end

      it "should include last hour of previous Saturday in weekly average" do
        @todays_activity.stub(:average) {|ms| ms.length}

        activity = @todays_activity.last_week_average_by_hour(@two_hours_ago)
        activity.should have(24).items
        activity.should == [7] * 24

      end
    end
  end

  describe "average calculation" do

    def measurements(*values)
      values.map { |value| FactoryGirl.build(:unique_visitors, value: value) }
    end

    it do
      @todays_activity.average(measurements()).should == 0
    end

    it do
      @todays_activity.average(measurements(50)).should == 50
    end

    it do
      @todays_activity.average(measurements(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)).should == 5.5
    end

  end

  describe "no data" do
    it "should return UTC 1970-01-01 midnight as live at date" do
      @todays_activity = TodaysActivityModel.new

      @todays_activity.live_at.should eql DateTime.parse("1970-01-01T00:00:00+00:00")
    end
  end
end
