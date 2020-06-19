# frozen_string_literal: true

class ApplicationController < ActionController::API
  class NotLoggedIn < StandardError; end

  after_action :refresh_tokens

  rescue_from NotLoggedIn do |err|
    render error_response(
      status: 403,
      message: I18n.t("action_requires_user")
    )
  end

  rescue_from ActionController::ParameterMissing do |err|
    render error_response(
      status: 400,
      message: err.message
    )
  end

  rescue_from ActiveRecord::RecordInvalid do |err|
    render error_response(
      status: 422,
      message: err.message
    )
  end

  def ensure_logged_in
    raise NotLoggedIn.new unless current_user
  end

  def error_response(status:, messages: [], message: nil)
    messages = messages.dup
    messages << message if message && message.size > 0
    {
      status: status,
      json: { messages: messages }
    }
  end

  def success_response
    {
      json: { messages: ["OK"] },
      status: 200
    }
  end

  def unprocessable_entity_response(errors = [])
    errors = [errors] unless Array === errors
    errors << "Unprocessable entity" if errors.size == 0
    {
      json: { messages: errors },
      status: 422
    }
  end

  def current_user
    if Rails.env.test? && user_id = request.headers[CurrentUserImplementer::TEST_USER_AUTH_TOKEN_HEADER]
      return @current_user ||= User.find(user_id)
    end
    current_user_implementer.current_user
  end

  def refresh_tokens
    current_user_implementer.refresh_tokens(response.headers)
  end

  private

  def current_user_implementer
    @current_user_implementer ||= CurrentUserImplementer.new(request.env)
  end
end
