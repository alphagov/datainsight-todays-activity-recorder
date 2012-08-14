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
    now = DateTime.now
    add_measurements(now - 2, now + 1)
    get '/todays-activity'
    last_response.should be_ok
    response = JSON.parse(last_response.body, :symbolize_names => true)

    hours = response[:values].map {|item| item[:hour_of_day]}
    hours.should == (0..23).to_a

    visitors_today = response[:values].reject {|item| item[:visitors][:today].nil? }
                             .map {|item| item[:visitors][:today] }
    visitors_today.should == [500] * now.hour

    visitors_yesterday = response[:values].map {|item| item[:visitors][:yesterday] }
    visitors_yesterday.should == [500] * 24

    monthly_average = response[:values].map {|item| item[:visitors][:monthly_average]}
    monthly_average.should == [500] * 24

    DateTime.parse(response[:live_at]).should be_an_instance_of(DateTime)
  end
end
