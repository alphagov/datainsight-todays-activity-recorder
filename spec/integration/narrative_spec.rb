require_relative "spec_helper"

describe("Narrative") do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    UniqueVisitors.destroy!
  end
  after(:each) do
    UniqueVisitors.destroy!
  end

  it "should return a valid narrative message JSON" do
    now = DateTime.now
    add_measurements(now - 4, now+1)
    get '/narrative'
    last_response.should be_ok
    response = JSON.parse(last_response.body, :symbolize_names => true)

    response[:content].should == "GOV.UK had 12 thousand visitors yesterday, about the same as the day before"
  end
end
