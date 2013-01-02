require "datainsight_recorder/datamapper_config"

module DataMapperConfig
  extend DataInsight::Recorder::DataMapperConfig


  def self.development_uri
    'mysql://root:@localhost/datainsights_todays_activity'
  end

  def self.production_uri
    'mysql://datainsight:@localhost/datainsights_todays_activity'
  end

  def self.test_uri
    'mysql://datainsight:@localhost/datainsights_todays_activity_test'
  end
end
