# frozen_string_literal: true
require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: messages
#
#  id               :bigint           not null, primary key
#  body             :text             not null
#  sender_user_id   :bigint           not null
#  receiver_user_id :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
