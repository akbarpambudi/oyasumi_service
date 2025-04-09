module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authorize_request
    attr_reader :current_user
  end

  private

  def authorize_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header
    @current_user = auth_service.authenticate_token(token:token)
  rescue => e
    render json: { error: "Unauthorized: #{e.message}" }, status: :unauthorized
  end

  def auth_service
    Application::AuthAppService.new(ar_user_repository)
  end

  def ar_user_repository
    Infrastructure::Repositories::ActiveRecord::ArUserRepository.new
  end
end
