class SleepRecordRecord < ApplicationRecord
  belongs_to :user, class_name: 'UserRecord', foreign_key: 'user_id'
end
