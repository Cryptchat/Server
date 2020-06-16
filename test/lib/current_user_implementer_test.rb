# frozen_string_literal: true

require 'test_helper'

class CurrentUserImplementerTest < ActiveSupport::TestCase
  def implementer(token, args = {}, url = '/')
    CurrentUserImplementer.new(Rack::MockRequest.env_for(
      url,
      args.merge(CurrentUserImplementer::AUTH_TOKEN_HEADER => token)
    ))
  end

  setup do
    @user = Fabricate(:user)
    @auth_token = AuthToken.generate(@user)
  end

  test 'sdsd' do
    freeze_time
    unhashed_token = @auth_token.unhashed_token
    assert_equal(false, @auth_token.seen)
    assert_equal(@user.id, @auth_token.user.id)
    assert_not_equal(unhashed_token, @auth_token.auth_token)
    assert_equal(AuthToken.hash_token(unhashed_token), @auth_token.auth_token)
    assert_equal(@auth_token.auth_token, @auth_token.previous_auth_token)

    impl = implementer(unhashed_token)
    assert_equal(@user.id, impl.current_user.id)
    res_headers = {}
    impl.refresh_tokens(res_headers)
    @auth_token.reload
    assert_equal(true, @auth_token.seen)
    assert_equal(AuthToken.hash_token(unhashed_token), @auth_token.auth_token)
    assert_equal(@auth_token.auth_token, @auth_token.previous_auth_token)
    assert_equal({}, res_headers)

    travel(16.minutes)
    time = Time.zone.now
    
    impl = implementer(unhashed_token)
    assert_equal(@user.id, impl.current_user.id)
    res_headers = {}
    impl.refresh_tokens(res_headers)
    @auth_token.reload
    assert_equal(false, @auth_token.seen)
    assert_equal(time, @auth_token.rotated_at)
    assert_not_equal(@auth_token.previous_auth_token, @auth_token.auth_token)
    assert_equal(AuthToken.hash_token(unhashed_token), @auth_token.previous_auth_token)
    assert_equal(
      AuthToken.hash_token(res_headers[CurrentUserImplementer::AUTH_TOKEN_HEADER]),
      @auth_token.auth_token
    )

    old_previous = @auth_token.previous_auth_token
    never_arrived_token = @auth_token.auth_token

    impl = implementer(unhashed_token)
    assert_equal(@user.id, impl.current_user.id)
    res_headers = {}
    impl.refresh_tokens(res_headers)
    @auth_token.reload
    assert_equal(false, @auth_token.seen)
    assert_equal(time, @auth_token.rotated_at)
    assert_not_equal(never_arrived_token, @auth_token.auth_token)
    assert_equal(old_previous, @auth_token.previous_auth_token)
    assert_equal(AuthToken.hash_token(unhashed_token), @auth_token.previous_auth_token)
    assert_equal(
      AuthToken.hash_token(res_headers[CurrentUserImplementer::AUTH_TOKEN_HEADER]),
      @auth_token.auth_token
    )
  end
end
