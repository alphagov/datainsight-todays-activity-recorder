require_relative "../spec_helper"
require_relative "../../lib/visitors_narrative"

describe "VisitorsNarrative" do

  it "should display correct narrative if there is a > 1% increase in visitors" do
    narrative = VisitorsNarrative.new(1200000,1000000)
    narrative.message.should == "GOV.UK had 1.2 million visitors yesterday, <green>an increase of 20%</green> from the day before"
  end

  it "should display correct narrative if there is a > 1% decrease in visitors" do
    narrative = VisitorsNarrative.new(1000000,1200000)
    narrative.message.should == "GOV.UK had 1 million visitors yesterday, <red>a decrease of 17%</red> from the day before"
  end

  it "should display correct narrative if there is a < 1% change in visitors" do
    narrative = VisitorsNarrative.new(1200000, 1205000)
    narrative.message.should == "GOV.UK had 1.2 million visitors yesterday, about the same as the day before"
  end

  it "should return an empty message if yesterdays visitors is nil" do
    narrative = VisitorsNarrative.new(nil, 1205000)
    narrative.message.should be_empty
  end

  it "should return a shortened message if visitors for the day before is missing" do
    narrative = VisitorsNarrative.new(1205000, nil)
    narrative.message.should  == "GOV.UK had 1.2 million visitors yesterday"
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

  describe "is_increase?" do
    it "should return true if the number of visitors has increased" do
      VisitorsMetric.new(100, 10).increase?.should be_true
    end

    it "should return false if the number of visitors has decreased" do
      VisitorsMetric.new(10, 100).increase?.should be_false
    end
  end
end