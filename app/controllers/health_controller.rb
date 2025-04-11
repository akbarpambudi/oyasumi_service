class HealthController < ApplicationController
  include Authentication
  skip_before_action :authorize_request

  def index
    render json: { status: 'ok' }, status: :ok
  end
end 