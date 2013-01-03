source "https://rubygems.org"
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem "rake", "0.9.2"
gem "datainsight_recorder", "0.1.0"
gem "airbrake", "3.1.5"

group :exposer do
  gem "unicorn"
  gem "sinatra"
end

group :recorder do
  gem "bunny"
  gem "gli", "1.6.0"
end

group :test do
  gem "rack-test"
  gem "rspec", "2.10.0"
  gem "ci_reporter"
  gem "factory_girl"
  gem "autotest"
  gem "timecop"
end

local_gemfile = File.dirname(__FILE__) + "/Gemfile.local.rb"
if File.file?(local_gemfile)
  self.instance_eval(Bundler.read_file(local_gemfile))
end
