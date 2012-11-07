require_relative '../spec_helper'

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

  describe "hour length validation" do
    it "should be valid if period is one hour" do
      unique_visitors = FactoryGirl.build(:unique_visitors,
                                          :start_at => DateTime.parse("2012-08-19T01:00:00+00:00"),
                                          :end_at => DateTime.parse("2012-08-19T02:00:00+00:00"))

      unique_visitors.should be_valid
    end

    it "should not be valid if period is bigger than one hour" do
      unique_visitors = FactoryGirl.build(:unique_visitors,
                                          :start_at => DateTime.parse("2012-08-19T01:00:00+00:00"),
                                          :end_at => DateTime.parse("2012-08-19T02:12:00+00:00"))

      unique_visitors.should_not be_valid
    end

    it "should not be valid if period is smaller than one hour" do
      unique_visitors = FactoryGirl.build(:unique_visitors,
                                          :start_at => DateTime.parse("2012-08-19T01:00:00+00:00"),
                                          :end_at => DateTime.parse("2012-08-19T01:59:00+00:00"))

      unique_visitors.should_not be_valid
    end

    it "should always be referencing a full hour" do
      unique_visitors = FactoryGirl.build(:unique_visitors,
                                          :start_at => DateTime.parse("2012-08-19T01:01:00+00:00"),
                                          :end_at => DateTime.parse("2012-08-19T02:01:00+00:00"))

      unique_visitors.should_not be_valid
    end
  end

  describe "field validation" do
    it "should be invalid if value is null" do
      unique_visitors = FactoryGirl.build(:unique_visitors, :value => nil)

      unique_visitors.should_not be_valid
    end

    it "should be invalid if value is negative" do
      unique_visitors = FactoryGirl.build(:unique_visitors, :value => -1)

      unique_visitors.should_not be_valid
    end

    it "should be valid if value is zero" do
      unique_visitors = FactoryGirl.build(:unique_visitors, :value => 0)

      unique_visitors.should be_valid
    end

    it "should have a non-null start_at" do
      unique_visitors = FactoryGirl.build(:unique_visitors, :start_at => nil)

      unique_visitors.should_not be_valid
    end

    it "should have a non-null end_at" do
      unique_visitors = FactoryGirl.build(:unique_visitors, :end_at => nil)

      unique_visitors.should_not be_valid
    end

    it "should have a non-null collected_at" do
      unique_visitors = FactoryGirl.build(:unique_visitors, :collected_at => nil)

      unique_visitors.should_not be_valid
    end
  end

  describe "last collected at" do
    it "should return the most recent collected at" do
      last_date = DateTime.new(2012, 2, 3, 4, 5, 6)
      first_date = DateTime.new(2011, 2, 3, 4, 5, 6)
      FactoryGirl.create(:unique_visitors, collected_at: last_date)
      FactoryGirl.create(:unique_visitors, collected_at: first_date)

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
      it "should return weekly average" do
        HourlyUniqueVisitors.stub(:average).and_return(400)

        activity = HourlyUniqueVisitors.last_week_average_by_hour(@two_hours_ago)
        activity.should have(24).items
        activity.should == [400] * 24
      end

      it "should include last hour of previous Saturday in weekly average" do
        HourlyUniqueVisitors.stub(:average) {|ms| ms.length}

        activity = HourlyUniqueVisitors.last_week_average_by_hour(@two_hours_ago)
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
      HourlyUniqueVisitors.average(measurements()).should == 0
    end

    it do
      HourlyUniqueVisitors.average(measurements(50)).should == 50
    end

    it do
      HourlyUniqueVisitors.average(measurements(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)).should == 5.5
    end

  end

end