# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < CryptchatIntegrationTest
  test '#sync requires logged in user' do
    Fabricate(:user)

    post '/sync/users.json'
    assert_equal(403, response.status)
    assert_equal(I18n.t("action_requires_user"), response.parsed_body["messages"].first)
  end

  test '#sync returns all users when no updated_at param is given' do
    sign_in

    users = [
      Fabricate(:user),
      Fabricate(:user),
      Fabricate(:user),
      Fabricate(:user)
    ]
    post '/sync/users.json'
    assert_equal(200, response.status)
    users_json = response.parsed_body["users"]
    assert_equal(4, users_json.size)
    assert_equal(users.map(&:id).sort, users_json.map { |u| u["id"] }.sort)
    assert_equal(
      users.map(&:updated_at).map { |t| (t.to_f * 1000).floor }.sort,
      users_json.map { |u| u["updated_at"] }.sort
    )
    assert_equal(
      users.map(&:created_at).map { |t| (t.to_f * 1000).floor }.sort,
      users_json.map { |u| u["created_at"] }.sort
    )
  end

  test '#sync returns all users updated at or after updated_at param' do
    sign_in
    time = 15.minutes.from_now
    users = [
      Fabricate(:user),
      Fabricate(:user),
      Fabricate(:user, created_at: time, updated_at: time),
      Fabricate(:user, created_at: time + 5.minutes, updated_at: time + 5.minutes)
    ]

    post '/sync/users.json', params: { updated_at: (time.to_f * 1000).floor }
    assert_equal(200, response.status)
    users_json = response.parsed_body["users"]
    assert_equal(1, users_json.size)
    assert_equal(users.last.id, users_json.first["id"])
  end
end
