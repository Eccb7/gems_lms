class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_user!

  respond_to :json

  protected

  def authenticate_api_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    return render_unauthorized unless token

    decoded_token = decode_jwt_token(token)
    return render_unauthorized unless decoded_token

    @current_user = User.find_by(id: decoded_token["user_id"])
    render_unauthorized unless @current_user&.active?
  end

  def current_user
    @current_user
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def render_not_found(resource = "Resource")
    render json: { error: "#{resource} not found" }, status: :not_found
  end

  def render_unprocessable_entity(errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end

  private

  def decode_jwt_token(token)
    JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")[0]
  rescue JWT::DecodeError
    nil
  end
end
