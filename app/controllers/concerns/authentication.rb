module Authentication
  extend ActiveSupport::Concern
  extend BeanDefinition

  included do
    before_action :authorize_request
    attr_reader :current_user
  end

  private

  def authorize_request
    header = request.headers["Authorization"]
    unless header
      render json: { error: "Unauthorized: Missing Authorization header" }, status: :unauthorized
      return
    end

    token = header.split(" ").last
    @current_user = auth_service.authenticate_token(token: token)
  rescue => e
    render json: { error: "Unauthorized: #{e.message}" }, status: :unauthorized
  end
end
