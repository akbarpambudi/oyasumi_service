class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  rescue_from BaseError, with: :handle_base_error

  private
  def handle_base_error(exception)
    Rails.logger.warn("Error occurred: #{exception.error_code} - #{exception.message}")

    render json: {
      error_code: exception.error_code,
      message: exception.message
    }, status: exception.http_status,content_type: "application/json"
  end
end
