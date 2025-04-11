module Application
  class FriendshipsAppService
    def initialize(
      relationship_repository = Domain::Repository::RelationshipRepository.new,
      user_repository = Domain::Repository::UserRepository.new,
      sleep_record_repository = Domain::Repository::SleepRecordRepository.new
    )
      @relationship_repo = relationship_repository
      @user_repo         = user_repository
      @sleep_record_repo = sleep_record_repository
    end

    # Follow a user
    def follow_user(follower_id:, followed_id:)
      # check if user exists
      followed_user = @user_repo.find_by_id(followed_id)
      raise Domain::Errors::UserNotFoundError unless followed_user

      existing = @relationship_repo.find_by(
        follower_id: follower_id,
        followed_id: followed_id
      )
      return :already_following if existing

      new_rel = Domain::Entities::Relationship.new(
        id: nil,
        follower_id: follower_id,
        followed_id: followed_id
      )
      @relationship_repo.create(new_rel)
      :success
    end

    # Unfollow a user
    def unfollow_user(follower_id:, followed_id:)
      followed_user = @user_repo.find_by_id(followed_id)
      raise Domain::Errors::UserNotFoundError unless followed_user

      existing = @relationship_repo.find_by(
        follower_id: follower_id,
        followed_id: followed_id
      )
      return :not_following unless existing

      @relationship_repo.delete(existing.id)
      :success
    end


    def fetch_following_sleep_records(user_id:, sort: :duration_desc, page: nil, per_page: nil)
      # 1) Get the list of followed user ids
      followed_ids = @relationship_repo.followed_ids_for(user_id)
      if page.nil? or page < 1
        page = 1
      end
      if per_page.nil? or per_page < 1
        per_page = 20
      end
      # 2) Retrieve completed records from the last 7 days for those followed users
      #    (Here, we assume your repository handles pagination + sorting in the DB.)

      records, total_count = @sleep_record_repo.find_completed_since_paginated(
        user_ids: followed_ids,
        since: 1.week.ago,
        sort: sort,
        page: page,
        per_page: per_page
      )

      {
        records: records,
        total_count: total_count,
        page: page,
        per_page: per_page
      }
    end
  end
end