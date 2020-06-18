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

  test '#update should... wait for it... update users' do
    user = sign_in(
      Fabricate(
        :user,
        country_code: '1234',
        phone_number: '555443333',
        instance_id: '840239402394',
        name: 'osama'
      )
    )
    put '/users.json', params: { user: {} }
    assert_equal(400, response.status)
    assert_equal('param is missing or the value is empty: user', response.parsed_body["messages"].first)
    user.reload
    assert_equal('osama', user.name)
    assert_equal('1234', user.country_code)
    assert_equal('555443333', user.phone_number)
    assert_equal('840239402394', user.instance_id)

    put '/users.json', params: { user: { name: 'johnny' } }
    assert_equal(200, response.status)
    user.reload
    assert_equal('johnny', user.name)
    assert_equal('1234', user.country_code)
    assert_equal('555443333', user.phone_number)
    assert_equal('840239402394', user.instance_id)

    put '/users.json', params: { user: {
      country_code: '76543',
      phone_number: '2902940240',
      instance_id: '04032940950235235'
    } }
    assert_equal(200, response.status)
    user.reload
    assert_equal('johnny', user.name)
    assert_equal('76543', user.country_code)
    assert_equal('2902940240', user.phone_number)
    assert_equal('04032940950235235', user.instance_id)
  end
end
