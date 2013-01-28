require_relative "spec_helper"

describe("Today's activity") do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  after(:each) do
    HourlyUniqueVisitors.destroy!
  end

  describe "check response" do
    before(:all) do
      now = DateTime.parse("2013-01-25 12:00:00")
      two_months_ago = now - 60

      @yesterday = now.to_date - 1

      add_measurements(two_months_ago, now)

      get '/todays-activity'

      last_response.should be_ok

      @response = JSON.parse(last_response.body, :symbolize_names => true)
    end

    it "should have id and web_url" do
      @response[:id].should == '/todays-activity'
      @response[:web_url].should == ''
    end

    it "should set the updated_at" do
      @response[:updated_at].should_not be_nil
      @response[:updated_at].should be_a(String)
    end

    it "should set the status to be ok" do
      @response[:response_info].should == {:status => 'ok'}
    end

    it "should have a metric visit" do
      @response[:details][:metric].should == 'visitors'
    end

    it "should have a for date" do
      lambda{ Date.parse(@response[:details][:for_date])}.should_not raise_error
      Date.parse(@response[:details][:for_date]).should == @yesterday
    end

    it "should have data for each hour" do
      (0..23).each do |hour|
        @response[:details][:data].should include({
                                                    :hour_of_day => hour,
                                                    :value => {
                                                      :yesterday => 500.0,
                                                      :historical_average => 500.0
                                                    }
                                                  })
      end
    end
  end
end
