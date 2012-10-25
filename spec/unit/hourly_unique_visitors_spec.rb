require_relative '../spec_helper'

describe HourlyUniqueVisitors do
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
end