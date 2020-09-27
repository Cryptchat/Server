# frozen_string_literal: true

require 'test_helper'

class AdminTokensControllerTest < CryptchatIntegrationTest
  test '#generate does not succeed with anon users' do
    post '/generate-admin-token.json'
    assert_equal(403, response.status)
    assert_equal(I18n.t('action_requires_user'), response.parsed_body['messages'].first)
  end

  test '#generate does not succeed with non-admin users' do
    user = Fabricate(:user)
    sign_in(user)
    post '/generate-admin-token.json'
    assert_equal(403, response.status)
    assert_equal(I18n.t('unauthorized_to_perform_action'), response.parsed_body['messages'].first)
  end

  test '#generate creates admin tokens for admin users' do
    admin = Fabricate(:user, admin: true)
    sign_in(admin)
    post '/generate-admin-token.json'
    assert_equal(200, response.status)
    token = response.parsed_body['key']
    assert_equal(64, token.size)
    records = AdminToken.where(user_id: admin.id)
    assert_equal(1, records.size)
    # we store a digest of the key, not the key itself
    refute_equal(token, records.first.token)
  end

  test '#generate deletes previous tokens when generating new one' do
    admin = Fabricate(:user, admin: true)
    sign_in(admin)
    post '/generate-admin-token.json'
    assert_equal(200, response.status)
    assert_equal(1, AdminToken.where(user_id: admin.id).count)
    token1 = response.parsed_body['key']
    assert_equal(64, token1.size)

    post '/generate-admin-token.json'
    assert_equal(200, response.status)
    assert_equal(1, AdminToken.where(user_id: admin.id).count)
    token2 = response.parsed_body['key']
    assert_equal(64, token2.size)
    refute_equal(token1, token2)
  end
end
