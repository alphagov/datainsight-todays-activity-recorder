require_relative '../spec_helper'

describe DailyUniqueVisitors do
  describe "hour length validation" do
    it "should be valid if period is a day" do
      unique_visitors = FactoryGirl.build(:daily_unique_visitors,
                                          :start_at => DateTime.parse("2012-08-19T00:00:00+00:00"),
                                          :end_at => DateTime.parse("2012-08-20T00:00:00+00:00"))

      unique_visitors.should be_valid
    end

    it "should not be valid if period is bigger than a day" do
      unique_visitors = FactoryGirl.build(:daily_unique_visitors,
                                          :start_at => DateTime.parse("2012-08-19T00:00:00+00:00"),
                                          :end_at => DateTime.parse("2012-08-21T00:00:00+00:00"))

      unique_visitors.should_not be_valid
    end

    it "should not be valid if period is smaller than a day" do
      unique_visitors = FactoryGirl.build(:daily_unique_visitors,
                                          :start_at => DateTime.parse("2012-08-19T00:00:00+00:00"),
                                          :end_at => DateTime.parse("2012-08-19T23:59+00:00"))

      unique_visitors.should_not be_valid
    end

    it "should always be referencing midnight" do
      unique_visitors = FactoryGirl.build(:daily_unique_visitors,
                                          :start_at => DateTime.parse("2012-08-19T01:01:00+00:00"),
                                          :end_at => DateTime.parse("2012-08-20T01:01:00+00:00"))

      unique_visitors.should_not be_valid
    end
  end

  describe "field validation" do
    it "should be invalid if value is null" do
      unique_visitors = FactoryGirl.build(:daily_unique_visitors, :value => nil)

      unique_visitors.should_not be_valid
    end

    it "should be invalid if value is negative" do
      unique_visitors = FactoryGirl.build(:daily_unique_visitors, :value => -1)

      unique_visitors.should_not be_valid
    end

    it "should be valid if value is zero" do
      unique_visitors = FactoryGirl.build(:daily_unique_visitors, :value => 0)

      unique_visitors.should be_valid
    end

    it "should have a non-null start_at" do
      unique_visitors = FactoryGirl.build(:daily_unique_visitors, :start_at => nil)

      unique_visitors.should_not be_valid
    end

    it "should have a non-null end_at" do
      unique_visitors = FactoryGirl.build(:daily_unique_visitors, :end_at => nil)

      unique_visitors.should_not be_valid
    end

    it "should have a non-null collected_at" do
      unique_visitors = FactoryGirl.build(:daily_unique_visitors, :collected_at => nil)

      unique_visitors.should_not be_valid
    end
  end

  describe "visitors_for" do
    after(:each) do
      DailyUniqueVisitors.destroy!
    end

    it "should return the total visitors for a given date" do
      date = DateTime.new(2012, 5, 5, 0, 0, 0)

      FactoryGirl.create(:daily_unique_visitors,
                         :value => 12000,
                         :start_at => date,
                         :end_at => date + 1)

      FactoryGirl.create(:daily_unique_visitors,
                         :value => 12999,
                         :start_at => date -1,
                                           :end_at => date)

      FactoryGirl.create(:daily_unique_visitors,
                         :value => 1700000,
                         :start_at => date + 1,
                         :end_at => date + 2)

      visitors_for_date = DailyUniqueVisitors.visitors_for(date)

      visitors_for_date.should == 12000
    end

    it "should return nil if data is missing" do
      date = DateTime.new(2012, 5, 5, 0, 0, 0)

      visitors_for_date = DailyUniqueVisitors.visitors_for(date)

      visitors_for_date.should be_nil
    end

  end

end