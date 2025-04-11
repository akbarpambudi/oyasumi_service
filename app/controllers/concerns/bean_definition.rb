module BeanDefinition
  extend ActiveSupport::Concern
  private
  def auth_service
    Application::AuthAppService.new(user_repository)
  end

  def users_service
    Application::UsersAppService.new(user_repository)
  end

  def friendships_service
    Application::FriendshipsAppService.new(relationship_repository, user_repository,sleep_record_repository)
  end

  def sleep_records_service
    Application::SleepRecordsAppService.new(sleep_record_repository)
  end

  def user_repository
    Infrastructure::Repositories::ActiveRecord::ArUserRepository.new
  end

  def relationship_repository
    Infrastructure::Repositories::ActiveRecord::ArRelationshipRepository.new
  end

  def sleep_record_repository
    base_repository = Infrastructure::Repositories::ActiveRecord::ArSleepRecordRepository.new
    Infrastructure::Repositories::ActiveRecord::CachedSleepRecordRepository.new(base_repository)
  end
end

