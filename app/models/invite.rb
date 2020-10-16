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
