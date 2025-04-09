class CreateUserRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :user_records do |t|
      t.string :name
      t.string :email
      t.string :encrypted_password

      t.timestamps
    end
  end
end
