require_relative "spec_helper"

describe("Narrative") do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    HourlyUniqueVisitors.destroy!
  end
  after(:each) do
    HourlyUniqueVisitors.destroy!
  end

  it "should return a valid narrative message JSON" do
    some_time = DateTime.new(1985, 1, 1, 19, 55)
    yesterday = DateTime.new(1984, 12, 31)
    the_day_before = DateTime.new(1984, 12, 30)

    Timecop.travel(some_time) do
      FactoryGirl.create(:daily_unique_visitors,
                         :value => 11999,
                         :start_at => the_day_before,
                         :end_at => the_day_before + 1
      )

      FactoryGirl.create(:daily_unique_visitors,
                         :value => 12000,
                         :start_at => yesterday,
                         :end_at => yesterday + 1
      )
      get '/narrative'
      last_response.should be_ok
      response = JSON.parse(last_response.body, :symbolize_names => true)

      response.should have_key(:id)
      response.should have_key(:web_url)
      response.should have_key(:updated_at)
      response[:response_info][:status].should == "ok"

      data = response[:details][:data]
      data[:content].should == "GOV.UK had 12 thousand visitors yesterday, about the same as the day before"
    end
  end


end
