require 'dm-constraints'
require 'dm-migrations'

module DataMapperConfig
  def self.configure(env=ENV["RACK_ENV"])
    case (env or "default").to_sym
      when :test
        DataMapperConfig.configure_test
      when :production
        DataMapperConfig.configure_production
      else
        DataMapperConfig.configure_development
    end
  end

  private

  def self.configure_development
    DataMapper::Logger.new($stdout, :debug)
    DataMapper.setup(:default, 'mysql://root:@localhost/datainsights_todays_activity')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  def self.configure_production
    DataMapper.setup(:default, 'mysql://root:@localhost/datainsights_todays_activity')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  def self.configure_test
    DataMapper.setup(:default, 'mysql://datainsight:datainsight@localhost/datainsights_todays_activity_test')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end
end
