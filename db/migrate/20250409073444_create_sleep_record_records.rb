class CreateSleepRecordRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_record_records do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :user_id

      t.timestamps
    end
  end
end
