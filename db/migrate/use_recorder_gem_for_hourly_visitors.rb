require "data_mapper"
require "dm-migrations/migration_runner"

migration 2, :use_recorder_gem_for_hourly_visitors do
  up do
    modify_table :hourly_unique_visitors do
      drop_column :updated_at
      drop_column :created_at
      add_column :source, String, allow_nil: false
    end
  end
end