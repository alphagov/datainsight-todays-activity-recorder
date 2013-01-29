require_relative "../spec_helper"

describe HourlyUniqueVisitorsCollection do

  it "should create a collection for a given period" do



    HourlyUniqueVisitors.should_receive(:period).with(DateTime.parse("2012-12-09 00:00:00"), DateTime.parse("2013-01-20 00:00:00")).and_return( [ :result ] )

    collection = HourlyUniqueVisitorsCollection.six_week_period_until(DateTime.parse("2013-01-20 12:15:45"))

    collection.results.should == [ :result ]
  end

  it "should initialize from a collection of HourlyUniqueVisitors" do
    period = 12.times.map { HourlyUniqueVisitors.new }
    HourlyUniqueVisitorsCollection.new(period)
  end

  it "should filter by day" do
    this_monday = FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-28 00:00:00"))
    last_monday = FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-21 00:00:00"))
    some_sunday = FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-27 00:00:00"))

    visitors_collection = [
      this_monday,
      some_sunday,
      last_monday,
    ]

    filter_for_monday = HourlyUniqueVisitorsCollection.new(visitors_collection).filter_by_day(Day::MONDAY).results
    filter_for_sunday = HourlyUniqueVisitorsCollection.new(visitors_collection).filter_by_day(Day::SUNDAY).results

    filter_for_monday.should == [this_monday, last_monday]
    filter_for_sunday.should == [some_sunday]
  end

  it "should compute average by hour" do
    visitors_collection = [
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-28 00:00:00"), value: 20),
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-28 01:00:00"), value: 30),
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-29 00:00:00"), value: 40),
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-29 01:00:00"), value: 31),
    ]

    average = HourlyUniqueVisitorsCollection.new(visitors_collection).hourly_average

    average[0].should == 30
    average[1].should == 30.5

  end

  it "should calculate the average for a lot of numbers for the same day" do
    visitors_collection = [
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-29 08:00:00"), value: 70000),
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-22 08:00:00"), value: 80000),
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-15 08:00:00"), value: 71000),
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-8 08:00:00"), value: 86000),
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-1 08:00:00"), value: 67000),
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2012-12-25 08:00:00"), value: 80002),
    ]

    tuesdays = HourlyUniqueVisitorsCollection.new(visitors_collection).filter_by_day(Day::TUESDAY)

    tuesdays.results.should have(6).records

    tuesdays.hourly_average[8].should == 75667
  end

  it "should return averages with hour as index" do
    visitors_collection = [
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-29 08:00:00"), value: 25),
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-28 08:00:00"), value: 15)
    ]

    average = HourlyUniqueVisitorsCollection.new(visitors_collection).hourly_average

    average[8].should == 20
  end

  it "should always return 24 averages (nil padded)" do
    visitors_collection = [
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-29 08:00:00"), value: 25),
      FactoryGirl.build(:hourly_unique_visitors, start_at: DateTime.parse("2013-01-28 08:00:00"), value: 15)
    ]

    average = HourlyUniqueVisitorsCollection.new(visitors_collection).hourly_average

    average[0].should == nil
    average[23].should == nil
    average.should have(24).averages
  end
end