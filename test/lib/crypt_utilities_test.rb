# frozen_string_literal: true

require 'test_helper'

class CryptUtilitiesTest < ActiveSupport::TestCase
  test "#generate_digits_token generates correct length tokens" do
    SecureRandom.stub(:rand, 0.17939060859547418) do
      assert_equal("1", CryptUtilities.generate_digits_token(1))
      assert_equal("17", CryptUtilities.generate_digits_token(2))
      assert_equal("179", CryptUtilities.generate_digits_token(3))
      assert_equal("1793", CryptUtilities.generate_digits_token(4))
      assert_equal("17939", CryptUtilities.generate_digits_token(5))
      assert_equal("179390", CryptUtilities.generate_digits_token(6))
      assert_equal("1793906", CryptUtilities.generate_digits_token(7))
      assert_equal("17939060", CryptUtilities.generate_digits_token(8))
    end

    SecureRandom.stub(:rand, 0.9999999999999999) do
      assert_equal("9", CryptUtilities.generate_digits_token(1))
      assert_equal("99", CryptUtilities.generate_digits_token(2))
    end

    SecureRandom.stub(:rand, 0.0000000000000000001) do
      assert_equal("1", CryptUtilities.generate_digits_token(1))
      assert_equal("10", CryptUtilities.generate_digits_token(2))
    end
  end
end
