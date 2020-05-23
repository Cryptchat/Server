# frozen_string_literal: true
require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase
  include HasPhoneNumberTest

  test "#verify works" do
    record = Registration.new(phone_number: "11", country_code: "11")
    record.generate_token!
    result = record.verify(record.verification_token)
    assert(result[:success])
    assert_nil(result[:reason])
  end

  test "#verify doesn't verify if record is too old" do
    record = Registration.new(phone_number: "11", country_code: "11")
    record.generate_token!

    record.created_at = record.updated_at = 20.minutes.ago
    record.save!

    result = record.verify(record.verification_token)
    assert_not(result[:success])
    assert_equal(I18n.t("too_much_time_passed"), result[:reason])
  end

  test "#verify doesn't verify if incorrect token is given" do
    record = Registration.new(phone_number: "11", country_code: "11")
    record.generate_token!

    result = record.verify("aaaabbbb")
    assert_not(result[:success])
    assert_equal(I18n.t("incorrect_code"), result[:reason])
  end

  test "#verify doesn't verify if record is already verified aka has user_id" do
    user = Fabricate(:user)
    record = Registration.new(phone_number: "11", country_code: "11", user_id: user.id)
    record.generate_token!
    result = record.verify(record.verification_token)
    assert_not(result[:success])
    assert_equal(I18n.t("number_already_registered"), result[:reason])
  end

  test "#generate_token! resets created_at and updated_at and fills verification_token_hash and salt" do
    old = 20.minutes.ago
    record = Registration.new(phone_number: "11", country_code: "11", created_at: old, updated_at: old)
    record.generate_token!
    assert_not_equal(old.to_i, record.created_at.to_i)
    assert_not_equal(old.to_i, record.updated_at.to_i)

    record.created_at = record.updated_at = old
    record.save!
    assert_equal(old.to_i, record.created_at.to_i)
    assert_equal(old.to_i, record.updated_at.to_i)

    record.generate_token!
    assert_not_equal(old.to_i, record.created_at.to_i)
    assert_not_equal(old.to_i, record.updated_at.to_i)
  end

  test "verification_token is not stored in the database and is 8 digits long" do
    user = Fabricate(:user)
    record = Registration.new(phone_number: "11", country_code: "11", user_id: user.id)
    record.generate_token!
    record.save!
    assert_not_equal(record.verification_token_hash, record.verification_token)
    assert_equal(8, record.verification_token.size)
    assert_equal(64, record.verification_token_hash.size)
  end
end

# == Schema Information
#
# Table name: registrations
#
#  id                      :bigint           not null, primary key
#  verification_token_hash :string(64)       not null
#  salt                    :string(32)       not null
#  country_code            :string(10)       not null
#  phone_number            :string(50)       not null
#  user_id                 :bigint
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_registrations_on_country_code_and_phone_number  (country_code,phone_number) UNIQUE
#
