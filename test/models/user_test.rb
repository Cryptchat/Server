# frozen_string_literal: true
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include HasPhoneNumberTest

  test "#atomic_delete_and_return_ephemeral_key delets and returns a key" do
    user = Fabricate(:user)
    user2 = Fabricate(:user)
    keys = %w[key1 key2]
    user.add_ephemeral_keys(keys)
    user2.add_ephemeral_keys(keys)
    key = user.atomic_delete_and_return_ephemeral_key
    assert_equal(user.id, key.user_id)
    assert_includes(keys, key.key)
    assert_equal(keys - [key.key], user.ephemeral_keys.pluck(:key))
    assert_equal(1, user.ephemeral_keys.count)
    assert_equal(2, user2.ephemeral_keys.count)
    assert_equal(keys, user2.ephemeral_keys.pluck(:key).sort)

    key2 = user2.atomic_delete_and_return_ephemeral_key
    assert_equal(user2.id, key2.user_id)
    assert_includes(keys, key2.key)
    assert_equal(keys - [key.key], user.ephemeral_keys.pluck(:key))
    assert_equal(keys - [key2.key], user2.ephemeral_keys.pluck(:key))
    assert_equal(1, user.ephemeral_keys.count)
    assert_equal(1, user2.ephemeral_keys.count)

    key3 = user2.atomic_delete_and_return_ephemeral_key
    assert_equal(user2.id, key2.user_id)
    assert_includes(keys, key2.key)
    assert_equal(keys - [key.key], user.ephemeral_keys.pluck(:key))
    assert_equal([], user2.ephemeral_keys.pluck(:key))
    assert_equal(1, user.ephemeral_keys.count)

    key4 = user2.atomic_delete_and_return_ephemeral_key
    assert_nil(key4)
    assert_equal([], user2.ephemeral_keys.pluck(:key))
    assert_equal(1, user.ephemeral_keys.count)
  end

  test "#add_ephemeral_keys insert keys" do
    user = Fabricate(:user)
    user.add_ephemeral_keys(%w[key1 key2])
    assert_equal(%w[key1 key2], user.ephemeral_keys.pluck(:key).sort)

    user.add_ephemeral_keys(%w[key3 key4])
    assert_equal(%w[key1 key2 key3 key4], user.ephemeral_keys.pluck(:key).sort)
  end

  test '#add_ephemeral_keys should not be vulnerable to SQL injections' do
    user = Fabricate(:user)
    injection = "key1', 563, '2020-05-23 22:47:35', '2020-05-23 22:47:35'); --"
    user.add_ephemeral_keys([injection])
    assert_equal([injection], user.ephemeral_keys.pluck(:key))
  end
end

# == Schema Information
#
# Table name: users
#
#  id           :bigint           not null, primary key
#  name         :string(255)
#  country_code :string(10)       not null
#  phone_number :string(50)       not null
#  instance_id  :string
#  identity_key :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_users_on_country_code_and_phone_number  (country_code,phone_number) UNIQUE
#  index_users_on_identity_key                   (identity_key) UNIQUE
#  index_users_on_instance_id                    (instance_id) UNIQUE
#
