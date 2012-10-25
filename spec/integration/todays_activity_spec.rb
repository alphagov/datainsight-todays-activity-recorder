require_relative "spec_helper"

describe("Today's activity") do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  after(:each) do
    HourlyUniqueVisitors.destroy!
  end

  it "should return JSON data" do
    now = DateTime.now
    add_measurements(now - 10, now + 1)
    get '/todays-activity'
    last_response.should be_ok
    response = JSON.parse(last_response.body, :symbolize_names => true)

    hours = response[:values].map {|item| item[:hour_of_day]}
    hours.should == (0..23).to_a

    visitors_yesterday = response[:values].map {|item| item[:visitors][:yesterday] }
    visitors_yesterday.should == [500] * 24

    last_week_average = response[:values].map {|item| item[:visitors][:last_week_average]}
    last_week_average.should == [500] * 24

    DateTime.parse(response[:live_at]).should be_an_instance_of(DateTime)
    DateTime.parse(response[:live_at]).should be_within(Rational(1, 24)).of(DateTime.now)

    Date.parse(response[:for_date]).should be_an_instance_of(Date)
    Date.parse(response[:for_date]).should == Date.today - 1
  end
end
