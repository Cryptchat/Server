# frozen_string_literal: true

require 'test_helper'

class CountriesTest < ActiveSupport::TestCase
  test '.flag_for returns emoji flag of given country' do
    assert_equal('🇸🇦', Countries.flag_for('SA'))
    assert_equal('🇯🇴', Countries.flag_for('JO'))
  end

  test '.from_id returns country object for given id' do
    assert_equal('+966', Countries.from_id('sa')[:country_code])
    assert_equal('+966', Countries.from_id('Sa')[:country_code])
    assert_equal('+966', Countries.from_id(:SA)[:country_code])
    assert_equal('+966', Countries.from_id(:sa)[:country_code])

    assert_equal('+962', Countries.from_id('jo')[:country_code])
    assert_equal('+962', Countries.from_id('Jo')[:country_code])
    assert_equal('+962', Countries.from_id(:JO)[:country_code])
    assert_equal('+962', Countries.from_id(:jo)[:country_code])

    assert_nil(Countries.from_id(:ww))
  end

  test '.valid_number? validates number' do
    refute(Countries.valid_number?(:SA, ' '))
    assert(Countries.valid_number?(:SA, '51 234 5678'))
    refute(Countries.valid_number?(:SA, '21 234 5678'))
    assert(Countries.valid_number?(:SA, '51234 5678'))
    assert(Countries.valid_number?(:SA, '512345678'))
    refute(Countries.valid_number?(:SA, '212345678'))
    refute(Countries.valid_number?(:SA, '5123456781'))
    refute(Countries.valid_number?(:SA, '51234567'))

    refute(Countries.valid_number?(:JO, ' '))
    assert(Countries.valid_number?(:JO, '9 1234 5678'))
    assert(Countries.valid_number?(:JO, '912345678'))
    assert(Countries.valid_number?(:JO, '91234 5678'))
    refute(Countries.valid_number?(:JO, '91234678'))
    refute(Countries.valid_number?(:JO, '9123467811'))
  end
end
