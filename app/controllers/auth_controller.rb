class AuthController < ApplicationController
  include BeanDefinition
  def sign_in
    token = auth_service.sign_in(email: params[:email], plain_password: params[:password])
    render json: { token: token }, status: :ok, content_type: "application/json"
  end

  def sign_up
    user = auth_service.sign_up(email: params[:email],name: params[:name], plain_password: params[:password])
    render json: {
      id: user.id,
      email: user.email.value,
      name: user.name.value,
    }, status: :ok , content_type: "application/json"
  end
end
