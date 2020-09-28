# frozen_string_literal: true

class ApplicationController < ActionController::API
  REMAINING_KEYS_COUNT_HEADER = "Cryptchat-Remaining-Keys-Count"
  IS_ADMIN_HEADER = "Cryptchat-Admin"

  class NotLoggedIn < StandardError; end
  class Unauthorized < StandardError; end

  after_action :refresh_tokens
  after_action :include_cryptchat_headers

  rescue_from NotLoggedIn do |err|
    render error_response(
      status: 403,
      message: I18n.t("action_requires_user")
    )
  end

  rescue_from Unauthorized do |err|
    render error_response(
      status: 403,
      message: I18n.t("unauthorized_to_perform_action")
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

  protected

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

  def refresh_tokens
    current_user_implementer.refresh_tokens(response.headers)
  end

  def include_cryptchat_headers
    if current_user
      response.headers[REMAINING_KEYS_COUNT_HEADER] = current_user.ephemeral_keys_count
      response.headers[IS_ADMIN_HEADER] = current_user.admin
    end
  end

  def current_user
    current_user_implementer.current_user
  end

  private

  def current_user_implementer
    @current_user_implementer ||= CurrentUserImplementer.new(request)
  end
end
