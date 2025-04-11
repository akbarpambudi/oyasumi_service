class AddMetadataToSleepRecordRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :sleep_record_records, :metadata, :jsonb
  end
end
