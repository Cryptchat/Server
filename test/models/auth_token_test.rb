# frozen_string_literal: true
require 'test_helper'

class AuthTokenTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: auth_tokens
#
#  id                  :bigint           not null, primary key
#  auth_token          :string           not null
#  previous_auth_token :string           not null
#  user_id             :bigint           not null
#  rotated_at          :datetime         not null
#  seen                :boolean          default("false"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_auth_tokens_on_auth_token           (auth_token) UNIQUE
#  index_auth_tokens_on_previous_auth_token  (previous_auth_token) UNIQUE
#  index_auth_tokens_on_user_id              (user_id)
#
