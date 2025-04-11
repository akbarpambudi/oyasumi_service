class ApplicationController < ActionController::API
  include ActionController::RequestForgeryProtection
  
  protect_from_forgery with: :null_session
  rescue_from Domain::Errors::BaseError, with: :handle_domain_error
  before_action :set_cors_headers

  private

  def handle_domain_error(exception)
    render json: {
      error: exception.message,
      code: exception.error_code
    }, status: exception.status_code, content_type: "application/json"
  end

  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
  end
end
