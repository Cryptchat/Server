# frozen_string_literal: true

class CurrentUserImplementer
  AUTH_TOKEN_HEADER = "Cryptchat-Auth-Token"
  AUTH_USER_ID_HEADER = "Cryptchat-Auth-User-Id"

  def initialize(request)
    @request = request
  end

  def current_user
    return @current_user if @performed_lookup
    unhashed_token = @request.headers[AUTH_TOKEN_HEADER]
    user_id = @request.headers[AUTH_USER_ID_HEADER]&.to_i
    @auth_token ||= AuthToken.lookup(unhashed_token, user_id)
    @current_user ||= @auth_token&.user
    @performed_lookup = true
    @current_user
  end

  def refresh_tokens(headers)
    return unless @auth_token
    should_rotate = @auth_token.seen ? @auth_token.rotated_at < 15.minutes.ago : @auth_token.rotated_at < 1.minute.ago
    if should_rotate && @auth_token.rotate
      headers[AUTH_TOKEN_HEADER] = @auth_token.unhashed_token
    end
  end
end
