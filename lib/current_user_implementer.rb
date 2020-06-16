# frozen_string_literal: true

class CurrentUserImplementer
  AUTH_TOKEN_HEADER = "HTTP_CRYPTCHAT_AUTH_TOKEN"
  TEST_USER_AUTH_TOKEN_HEADER = "Cryptchat-Auth-Token-Tests"

  def initialize(env)
    @env = env
  end

  def current_user
    return @current_user if @performed_lookup
    unhashed_token = @env[AUTH_TOKEN_HEADER]
    @auth_token ||= AuthToken.lookup(unhashed_token)
    @current_user ||= @auth_token&.user
    @performed_lookup = true
    @current_user
  end

  def refresh_tokens(headers)
    if @auth_token && (@auth_token.rotated_at < 15.minutes.ago || !@auth_token.seen)
      if @auth_token.rotate
        headers[AUTH_TOKEN_HEADER] = @auth_token.unhashed_token
      end
    end
  end
end
