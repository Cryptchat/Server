# frozen_string_literal: true

module CurrentUser
  def current_user
    if Rails.env.test? && user_id = request.headers[CurrentUserImplementer::TEST_USER_AUTH_TOKEN_HEADER]
      return @current_user ||= User.find_by(id: user_id)
    end
    current_user_implementer.current_user
  end

  private

  def current_user_implementer
    @current_user_implementer ||= CurrentUserImplementer.new(request.env)
  end
end
