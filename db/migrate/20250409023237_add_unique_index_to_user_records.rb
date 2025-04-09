class AddUniqueIndexToUserRecords < ActiveRecord::Migration[8.0]
  def change
    add_index :user_records, [:email], unique: true
  end
end
