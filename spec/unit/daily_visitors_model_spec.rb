require "date"

require_relative "../spec_helper"
require_relative "../../lib/daily_visitors_model"

describe "Daily visitors model" do

  it "should return the total visitors for a given date" do
    date = DateTime.new(2012,5,5,0,0,0)
    add_measurements(date-1,date+2)
    model = DailyVisitorsModel.new()

    visitors_for_date = model.visitors_for(date)

    visitors_for_date.should == 12000
  end

end