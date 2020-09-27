# frozen_string_literal: true

require 'test_helper'

class AdminTokenTest < ActiveSupport::TestCase
  test '.create_for! deletes all previous keys and creates a new one for the given admin' do
    admin = Fabricate(:user, admin: true)
    assert_nil(admin.admin_token)
    token1 = Fabricate(:admin_token, user_id: admin.id)
    token2 = AdminToken.create_for!(admin)
    assert_equal([token2.id], AdminToken.where(user_id: admin.id).pluck(:id))
    assert_equal(admin.id, token2.user.id)
    admin.reload
    assert_equal(token2.id, admin.admin_token.id)
  end

  test '.create_for! sets unhashed_token attribute on the token record and returns the record' do
    admin = Fabricate(:user, admin: true)
    token = AdminToken.create_for!(admin)
    assert_equal(64, token.token.size)
    assert_equal(64, token.unhashed_token.size)
    refute_equal(token.unhashed_token, token.token)
    token = AdminToken.find(token.id)
    assert_nil(token.unhashed_token)
  end

  test '.lookup_admin can find admin via token and id' do
    admin = Fabricate(:user, admin: true)
    token = AdminToken.create_for!(admin)
    lookedup_admin = AdminToken.lookup_admin(token.unhashed_token, admin.id)
    assert_equal(admin.id, lookedup_admin.id)
  end

  test '.lookup_admin requires both token and id to be for the same admin' do
    admin = Fabricate(:user, admin: true)
    admin2 = Fabricate(:user, admin: true)
    token = AdminToken.create_for!(admin)
    token2 = AdminToken.create_for!(admin2)
    assert_nil(AdminToken.lookup_admin(token2.unhashed_token, admin.id))
    assert_nil(AdminToken.lookup_admin(token.unhashed_token, admin2.id))
    assert_equal(admin, AdminToken.lookup_admin(token.unhashed_token, admin.id))
    assert_equal(admin2, AdminToken.lookup_admin(token2.unhashed_token, admin2.id))
  end

  test '.lookup_admin does not work for non-admin users' do
    user = Fabricate(:user)
    token = AdminToken.create_for!(user)
    assert_nil(AdminToken.lookup_admin(token.unhashed_token, user.id))

    user.update!(admin: true)
    assert_equal(user, AdminToken.lookup_admin(token.unhashed_token, user.id))
  end
end

# == Schema Information
#
# Table name: admin_tokens
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  token        :string           not null
#  last_used_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_admin_tokens_on_user_id  (user_id) UNIQUE
#
