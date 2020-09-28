# frozen_string_literal: true

require 'test_helper'

class CurrentUserImplementerTest < ActiveSupport::TestCase
  def header_reformat(header)
    "HTTP_#{header.upcase.gsub('-', '_')}"
  end

  def implementer(token, user_id)
    CurrentUserImplementer.new(
      ActionDispatch::Request.new({
        header_reformat(CurrentUserImplementer::AUTH_TOKEN_HEADER) => token,
        header_reformat(CurrentUserImplementer::AUTH_USER_ID_HEADER) => user_id
      })
    )
  end

  setup do
    @user = Fabricate(:user)
    @auth_token = AuthToken.generate(@user)
  end

  test 'lookup requires user_id and token' do
    another_user = Fabricate(:user)
    unhashed_token = @auth_token.unhashed_token
    impl = implementer(unhashed_token, another_user.id)
    assert_nil(impl.current_user)
    impl = implementer(unhashed_token, @user.id)
    assert_equal(@user.id, impl.current_user.id)
  end

  test 'auth tokens rotation' do
    freeze_time
    unhashed_token = @auth_token.unhashed_token
    assert_equal(false, @auth_token.seen)
    assert_equal(@user.id, @auth_token.user.id)
    assert_not_equal(unhashed_token, @auth_token.auth_token)
    assert_equal(AuthToken.hash_token(unhashed_token), @auth_token.auth_token)
    assert_equal(@auth_token.auth_token, @auth_token.previous_auth_token)

    impl = implementer(unhashed_token, @user.id)
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

    impl = implementer(unhashed_token, @user.id)
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

    impl = implementer(unhashed_token, @user.id)
    assert_equal(@user.id, impl.current_user.id)
    res_headers = {}
    impl.refresh_tokens(res_headers)
    @auth_token.reload
    assert_equal(false, @auth_token.seen)
    assert_equal(old_previous, @auth_token.previous_auth_token)
    assert_equal({}, res_headers)

    travel(5.minutes)
    time = Time.zone.now
    impl = implementer(unhashed_token, @user.id)
    assert_equal(@user.id, impl.current_user.id)
    res_headers = {}
    impl.refresh_tokens(res_headers)
    @auth_token.reload
    assert_equal(false, @auth_token.seen)
    assert_equal(time, @auth_token.rotated_at)
    assert_equal(old_previous, @auth_token.previous_auth_token)
    assert_equal(AuthToken.hash_token(unhashed_token), @auth_token.previous_auth_token)
    assert_not_equal(never_arrived_token, @auth_token.auth_token)
    assert_not_equal(@auth_token.previous_auth_token, @auth_token.auth_token)
    assert_equal(
      AuthToken.hash_token(res_headers[CurrentUserImplementer::AUTH_TOKEN_HEADER]),
      @auth_token.auth_token
    )

    new_token = res_headers[CurrentUserImplementer::AUTH_TOKEN_HEADER]
    impl = implementer(new_token, @user.id)
    assert_equal(@user.id, impl.current_user.id)
    res_headers = {}
    impl.refresh_tokens(res_headers)
    @auth_token.reload
    assert_equal(true, @auth_token.seen)
    assert_equal(AuthToken.hash_token(unhashed_token), @auth_token.previous_auth_token)

    travel(16.minutes)
    time = Time.zone.now
    impl = implementer(new_token, @user.id)
    assert_equal(@user.id, impl.current_user.id)
    res_headers = {}
    impl.refresh_tokens(res_headers)
    @auth_token.reload
    assert_equal(false, @auth_token.seen)
    assert_equal(time, @auth_token.rotated_at)
    assert_not_equal(AuthToken.hash_token(unhashed_token), @auth_token.previous_auth_token)
    assert_equal(AuthToken.hash_token(new_token), @auth_token.previous_auth_token)
    assert_equal(
      AuthToken.hash_token(res_headers[CurrentUserImplementer::AUTH_TOKEN_HEADER]),
      @auth_token.auth_token
    )
  end
end
