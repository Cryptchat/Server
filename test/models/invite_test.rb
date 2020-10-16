require 'test_helper'

class InviteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: invites
#
#  id           :bigint           not null, primary key
#  inviter_id   :bigint           not null
#  country_code :string(10)       not null
#  phone_number :string(50)       not null
#  expires_at   :datetime         not null
#  claimed      :boolean          default("false"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_invites_on_country_code_and_phone_number  (country_code,phone_number) UNIQUE
#
