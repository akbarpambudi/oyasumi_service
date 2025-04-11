module Application
  class UsersAppService
    def initialize(user_repository = Domain::Repository::UserRepository.new)
      @user_repository = user_repository
    end

    def list_users(page:, per_page:)
      records, total_count = @user_repository.find_all_paginated(
        page: page,
        per_page: per_page
      )

      {
        page: page,
        per_page: per_page,
        total_count: total_count,
        records: records
      }
    end

    def get_user(id:)
      user = @user_repository.find_by_id(id)
      { user: user }
    end
  end
end 