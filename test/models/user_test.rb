# frozen_string_literal: true
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "#atomic_delete_and_return_ephemeral_key! delets and returns a key" do
    user = Fabricate(:user)
    user2 = Fabricate(:user)
    keys = gen_keys(1..2)
    user.add_ephemeral_keys!(keys)
    user2.add_ephemeral_keys!(keys)
    key = user.atomic_delete_and_return_ephemeral_key!
    mapped = { id: key.id_on_user_device, key: key.key }
    assert_equal(user.id, key.user_id)
    assert_equal(keys - [mapped], user_keys(user))
    assert_equal(1, user.ephemeral_keys.count)
    assert_equal(2, user2.ephemeral_keys.count)
    assert_equal(keys, user_keys(user2))

    key2 = user2.atomic_delete_and_return_ephemeral_key!
    mapped2 = { id: key2.id_on_user_device, key: key2.key }
    assert_equal(user2.id, key2.user_id)
    assert_equal(keys - [mapped2], user_keys(user2))
    assert_equal(keys - [mapped], user_keys(user))
    assert_equal(keys - [mapped2], user_keys(user2))
    assert_equal(1, user.ephemeral_keys.count)
    assert_equal(1, user2.ephemeral_keys.count)

    key3 = user2.atomic_delete_and_return_ephemeral_key!
    mapped3 = { id: key3.id_on_user_device, key: key3.key }
    assert_equal(user2.id, key3.user_id)
    assert_includes(keys, mapped3)
    assert_equal(keys - [mapped], user_keys(user))
    assert_equal([], user_keys(user2))
    assert_equal(1, user.ephemeral_keys.count)

    key4 = user2.atomic_delete_and_return_ephemeral_key!
    assert_nil(key4)
    assert_equal([], user2.ephemeral_keys.pluck(:key))
    assert_equal(1, user.ephemeral_keys.count)
  end

  test "#add_ephemeral_keys! inserts keys" do
    user = Fabricate(:user)
    keys = gen_keys(1..2)
    user.add_ephemeral_keys!(keys)
    assert_equal(keys, user_keys(user))

    keys2 = gen_keys(3..4)
    user.add_ephemeral_keys!(keys2)
    assert_equal(keys + keys2, user_keys(user))
  end

  test '#add_ephemeral_keys! should not be vulnerable to SQL injections' do
    user = Fabricate(:user)
    keys = gen_keys(1..1)
    injection = "key1', 563, '2020-05-23 22:47:35', '2020-05-23 22:47:35'); --"
    keys[0][:key] = injection
    user.add_ephemeral_keys!(keys)
    assert_equal([injection], user.ephemeral_keys.pluck(:key))
  end

  private

  def user_keys(user)
    user.ephemeral_keys.pluck(:id_on_user_device, :key)
      .map { |k| { id: k[0], key: k[1] } }
      .sort_by { |k| k[:key] }
  end

  def gen_keys(range)
    range.map do |n|
      { id: n, key: "key#{n}" }
    end
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
#  avatar_id    :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_users_on_country_code_and_phone_number  (country_code,phone_number) UNIQUE
#  index_users_on_identity_key                   (identity_key) UNIQUE
#  index_users_on_instance_id                    (instance_id) UNIQUE
#
