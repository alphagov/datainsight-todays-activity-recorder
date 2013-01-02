require "data_mapper"
require "dm-migrations/migration_runner"

migration 1, :use_recorder_gem_for_daily_visitors do
  up do
    modify_table :daily_unique_visitors do
      drop_column :updated_at
      drop_column :created_at
      add_column :source, String, allow_nil: false
    end
  end
end