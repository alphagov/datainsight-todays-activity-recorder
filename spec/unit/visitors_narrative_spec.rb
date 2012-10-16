require_relative "../spec_helper"
require_relative "../../lib/visitors_narrative"

describe "VisitorsNarrative" do

  it "should display correct narrative if there is a > 1% increase in visitors" do
    narrative = VisitorsNarrative.new(1200000,1000000)
    narrative.message.should == "GOV.UK had 1.2 million visitors yesterday, an increase of 20% from the day before"
  end

  it "should display correct narrative if there is a > 1% decrease in visitors" do
    narrative = VisitorsNarrative.new(1000000,1200000)
    narrative.message.should == "GOV.UK had 1 million visitors yesterday, a decrease of 17% from the day before"
  end

  it "should display correct narrative if there is a < 1% change in visitors" do
    narrative = VisitorsNarrative.new(1200000, 1205000)
    narrative.message.should == "GOV.UK had 1.2 million visitors yesterday, about the same as the day before"
  end
end

describe "VisitorsMetric" do

  describe "delta" do
    it "should have the percentage change in visitors (compared to the day before)" do
      VisitorsMetric.new(1200000,1000000).delta.should == 20
    end

    it "should have the percentage change in visitors to the nearest integer" do
      VisitorsMetric.new(1201000,1000000).delta.should == 20
    end
  end

  describe "yesterday" do
    it "should return a one sig-fig representation of yesterdays visitors" do
      VisitorsMetric.new(1200000,1000000).yesterday.should == "1.2 million"
    end

    it "should return a one sig-fig representation of yesterdays visitors 1" do
      VisitorsMetric.new(500000,1000000).yesterday.should == "0.5 million"
    end

    it "should return a one sig-fig representation of yesterdays visitors 2" do
      VisitorsMetric.new(490000,1000000).yesterday.should == "490 thousand"
    end
  end

  describe "change" do
    it "should return 'increase' if the number of visitors has increased" do
      VisitorsMetric.new(100, 10).change.should == "an increase"
    end

    it "should return 'decrease' if the number of visitors has decrease" do
      VisitorsMetric.new(10, 100).change.should == "a decrease"
    end
  end
end