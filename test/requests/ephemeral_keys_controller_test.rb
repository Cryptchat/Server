# frozen_string_literal: true
require 'test_helper'

class EphemeralKeysControllerTest < ActionDispatch::IntegrationTest
  test '#top_up complains when no keys param is given' do
    user = Fabricate(:user)
    post '/ephemeral-keys.json', params: { user_id: user.id }
    assert_equal(400, response.status)
    assert_equal("param is missing or the value is empty: keys", response.parsed_body["messages"].first)
  end

  test '#top_up complains when keys param is not an array' do
    user = Fabricate(:user)
    post '/ephemeral-keys.json', params: { user_id: user.id, keys: "dsa" }
    assert_equal(422, response.status)
    assert_equal(I18n.t("keys_param_must_string_array"), response.parsed_body["messages"].first)
  end

  test '#top_up complains when given too many keys' do
    user = Fabricate(:user)
    keys = (1..15).map { |n| "key#{n}" }
    post '/ephemeral-keys.json', params: { user_id: user.id, keys: keys }
    assert_equal(403, response.status)
    assert_equal(I18n.t("keys_count_exceeds_limit"), response.parsed_body["messages"].first)

    keys = (1..5).map { |n| "key#{n}" }
    post '/ephemeral-keys.json', params: { user_id: user.id, keys: keys }
    assert_equal(200, response.status)
    assert_equal(keys, user.ephemeral_keys.pluck(:key).sort)

    keys2 = (6..20).map { |n| "key#{n}" }
    post '/ephemeral-keys.json', params: { user_id: user.id, keys: keys2 }
    assert_equal(403, response.status)
    assert_equal(I18n.t("keys_count_exceeds_limit"), response.parsed_body["messages"].first)
    assert_equal(keys, user.ephemeral_keys.pluck(:key).sort)
  end

  test '#top_up adds keys' do
    user = Fabricate(:user)
    keys = (1..5).map { |n| "key#{n}" }
    post '/ephemeral-keys.json', params: { user_id: user.id, keys: keys }
    assert_equal(200, response.status)
    assert_equal(keys, user.ephemeral_keys.pluck(:key).sort)

    keys2 = (6..9).map { |n| "key#{n}" }
    post '/ephemeral-keys.json', params: { user_id: user.id, keys: keys2 }
    assert_equal(200, response.status)
    assert_equal(keys + keys2, user.ephemeral_keys.pluck(:key).sort)
  end
end
