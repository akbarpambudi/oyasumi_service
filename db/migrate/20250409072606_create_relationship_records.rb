class CreateRelationshipRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :relationship_records do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
  end
end
