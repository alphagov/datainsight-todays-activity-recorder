require "datainsight_recorder/migrations"

migration 1, :init_schema do
  up do
    if adapter.storage_exists?("migration_info")
      # reset data about old migrations
      execute "DELETE FROM migration_info"
    end

    unless adapter.storage_exists?("daily_unique_visitors")
      create_table :daily_unique_visitors do
        column :id, "INTEGER(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY" # Integer, serial: true
        column :collected_at, DateTime, allow_nil: false
        column :start_at,     DateTime, allow_nil: false
        column :end_at,       DateTime, allow_nil: false
        column :value,        Integer,  allow_nil: false
        column :source,       String,   allow_nil: false
      end
    end

    unless adapter.storage_exists?("hourly_unique_visitors")
      create_table :hourly_unique_visitors do
        column :id, "INTEGER(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY" # Integer, serial: true
        column :collected_at, DateTime, allow_nil: false
        column :start_at,     DateTime, allow_nil: false
        column :end_at,       DateTime, allow_nil: false
        column :value,        Integer,  allow_nil: false
        column :source,       String,   allow_nil: false
      end
    end
  end

  down do
    drop_table :daily_unique_visitors
    drop_table :hourly_unique_visitors
  end
end
