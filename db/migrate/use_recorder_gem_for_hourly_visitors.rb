require "data_mapper"
require "dm-migrations/migration_runner"



migration 2, :use_recorder_gem_for_hourly_visitors do
  up do
    modify_table :hourly_unique_visitors do
      if adapter.field_exists?("hourly_unique_visitors", "updated_at")
        drop_column :updated_at
      end

      if adapter.field_exists?("hourly_unique_visitors", "created_at")
        drop_column :created_at
      end

      
      unless adapter.field_exists?("hourly_unique_visitors", "source")
        add_column :source, String, allow_nil: false
      end
    end
  end
end