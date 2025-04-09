# frozen_string_literal: true

class BaseError < StandardError
  attr_reader :error_code, :http_status

  def initialize(message: "", error_code: "UNKNOWN_ERROR", http_status: 500)
    super(message)
    @error_code = error_code
    @http_status = http_status
  end
end