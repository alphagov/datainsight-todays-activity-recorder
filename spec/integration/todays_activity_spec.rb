require_relative "spec_helper"

describe("Today's activity") do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  after(:each) do
    UniqueVisitors.destroy!
  end

  it "should return JSON data" do
    add_measurements(DateTime.now - 2, DateTime.now + 1)
    get '/todays-activity'
    last_response.should be_ok
    result = JSON.parse(last_response.body, :symbolize_names => true)
      .reject {|item| item[:visitors][:today].nil? }
      .map {|item| [item[:hour_of_day], item[:visitors][:today]] }
    result.should == TodaysActivity.visitors_today
      .map {|item| [item.start_at.hour, item.value]}

    result = JSON.parse(last_response.body, :symbolize_names => true)
    .reject {|item| item[:visitors][:yesterday].nil? }
    .map {|item| [item[:hour_of_day], item[:visitors][:yesterday]] }
    result.should == TodaysActivity.visitors_yesterday
    .map {|item| [item.start_at.hour, item.value]}

    hours = JSON.parse(last_response.body, :symbolize_names => true)
      .map {|item| item[:hour_of_day]}
    hours.should == (0..23).to_a

  end
end