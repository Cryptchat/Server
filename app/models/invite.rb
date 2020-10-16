# frozen_string_literal: true

class Invite < ApplicationRecord
  include HasPhoneNumber

  belongs_to :inviter, foreign_key: :inviter_id, class_name: 'User'
  validates :inviter_id, :expires_at, presence: true

  def self.invite_for(country_code, phone_number)
    find_by(country_code: country_code, phone_number: phone_number, claimed: false)
  end

  def expired?
    Time.zone.now > self.expires_at
  end

  def claim!
    update!(claimed: true)
  end
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
