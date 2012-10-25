require "date"

require_relative "../spec_helper"
require_relative "../../lib/daily_visitors_model"

describe "Daily visitors model" do

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

    model = DailyVisitorsModel.new

    visitors_for_date = model.visitors_for(date)

    visitors_for_date.should == 12000
  end

  it "should return nil if data is missing" do
    date = DateTime.new(2012, 5, 5, 0, 0, 0)

    model = DailyVisitorsModel.new

    visitors_for_date = model.visitors_for(date)

    visitors_for_date.should be_nil
  end

end