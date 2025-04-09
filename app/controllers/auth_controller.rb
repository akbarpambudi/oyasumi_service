class AuthController < ApplicationController
  def sign_in
    token = auth_service.sign_in(email: params[:email], plain_password: params[:password])
    render json: { token: token }, status: :ok, content_type: "application/json"
  end

  def sign_up
    auth_service.sign_up(email: params[:email],name: params[:name], plain_password: params[:password])
    render json: {
      email: params[:email],
      name: params[:name],
    }, status: :ok , content_type: "application/json"
  end

  private

  def auth_service
    Application::AuthAppService.new(ar_user_repository)
  end

  def ar_user_repository
    Infrastructure::Repositories::ActiveRecord::ArUserRepository.new
  end
end