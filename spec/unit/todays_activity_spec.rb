require "date"

require_relative "../spec_helper"
require_relative "../../lib/todays_activity"

describe "TodaysActivity" do

  before(:each) do
    @two_hours_ago = DateTime.new(2012, 8, 16, 9, 50, 0)
    @now = DateTime.new(2012, 8, 16, 11, 50, 0)

    @todays_activity = TodaysActivity.new
  end

  after(:each) do
    UniqueVisitors.destroy!
  end

  describe "todays activity" do
    it "should assemble the result" do
      @todays_activity.stub(:live_at).and_return(@two_hours_ago)
      @todays_activity.stub(:visitors_today_by_hour).and_return([200, 200, 200, 200, nil, 200, 200])
      @todays_activity.stub(:visitors_yesterday_by_hour).and_return([100]*24)
      @todays_activity.stub(:last_month_average_by_hour).and_return([300]*24)

      activity = @todays_activity.todays_activity
      activity[:live_at].should == @two_hours_ago
      activity[:values].should have(24).items
      activity[:values][0].should == {
        :hour_of_day => 0,
        :visitors => {
          :today => 200,
          :yesterday => 100,
          :monthly_average => 300
        }}
      activity[:values][4].should == {
        :hour_of_day => 4,
        :visitors => {
          :today => nil,
          :yesterday => 100,
          :monthly_average => 300
        }}
      activity[:values][7].should == {
        :hour_of_day => 7,
        :visitors => {
          :yesterday => 100,
          :monthly_average => 300
        }}
      activity[:values][23].should == {
        :hour_of_day => 23,
        :visitors => {
          :yesterday => 100,
          :monthly_average => 300
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

    describe "todays visitors" do

      it "should return todays visitors" do

        activity = @todays_activity.visitors_today_by_hour(@two_hours_ago)

        activity.should have(9).items
        activity.should be_a(Array)
        activity.should == [500]*9
      end

      it "should return todays visitors" do
        UniqueVisitors.all(
          :start_at.gte => (@two_hours_ago- Rational(7, 24)),
          :end_at.lte => (@two_hours_ago- Rational(3, 24))
        ).destroy!

        activity = @todays_activity.visitors_today_by_hour(@two_hours_ago)

        activity.should have(9).items
        activity.should be_a(Array)
        activity.should == [500, 500, 500, nil,nil,nil, 500, 500, 500]
      end


    end


    describe "yesterdays visitors" do

      it "should return yesterdays visitors" do

        activity = @todays_activity.visitors_yesterday_by_hour(@two_hours_ago)
        activity.should have(24).items
        activity.should == [500] * 24
      end
    end

    describe "monthly average" do


      it "should return monthly average" do
        @todays_activity.stub(:average).and_return(400)

        activity = @todays_activity.last_month_average_by_hour(@two_hours_ago)
        activity.should have(24).items
        activity.should == [400] * 24
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
end
