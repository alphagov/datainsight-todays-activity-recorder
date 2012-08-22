source "https://rubygems.org"

gem "rake", "0.9.2"
gem "sinatra"
gem "bunny"
gem "gli", "1.6.0"
gem "data_mapper", "1.2.0"
gem "dm-mysql-adapter", "1.2.0"
gem "unicorn"

group :test do
  gem "dm-sqlite-adapter", "1.2.0"
  gem "rack-test"
  gem "rspec", "2.10.0"
  gem "ci_reporter"
  gem "factory_girl"
  gem "autotest"
end

local_gemfile = File.dirname(__FILE__) + "/Gemfile.local.rb"
if File.file?(local_gemfile)
  self.instance_eval(Bundler.read_file(local_gemfile))
end
