class ApplicationController < ActionController::Base
  rescue_from BaseError, with: :handle_base_error

  private
  def handle_base_error(exception)
    Rails.logger.warn("Error occurred: #{exception.error_code} - #{exception.message}")

    render json: {
      error_code: exception.error_code,
      message: exception.message
    }, status: exception.http_status
  end
end
