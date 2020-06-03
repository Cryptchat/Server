# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test '#sync returns all users when no updated_at param is given' do
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
      users.map(&:updated_at).map { |t| (t.to_f * 1000).round }.sort,
      users_json.map { |u| u["updated_at"] }.sort
    )
    assert_equal(
      users.map(&:created_at).map { |t| (t.to_f * 1000).round }.sort,
      users_json.map { |u| u["created_at"] }.sort
    )
  end

  test '#sync returns all users updated at or after updated_at param' do
    time = 15.minutes.from_now
    time2 = 20.minutes.from_now
    users = [
      Fabricate(:user),
      Fabricate(:user),
      Fabricate(:user, created_at: time, updated_at: time),
      Fabricate(:user, created_at: time2, updated_at: time2)
    ]

    post '/sync/users.json', params: { updated_at: time.to_f }
    assert_equal(200, response.status)
    users_json = response.parsed_body["users"]
    assert_equal(2, users_json.size)
    assert_equal(users.last(2).map(&:id).sort, users_json.map { |u| u["id"] }.sort)

    post '/sync/users.json', params: { updated_at: time2.to_f }
    assert_equal(200, response.status)
    users_json = response.parsed_body["users"]
    assert_equal(1, users_json.size)
    assert_equal(users.last.id, users_json.first["id"])
    assert_in_delta((time2.to_f * 1000).round, users_json.first["updated_at"], 0.01)
  end
end
