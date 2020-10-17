# frozen_string_literal: true

class Invite < ApplicationRecord
  include HasPhoneNumber
  class InviteError < StandardError; end

  belongs_to :inviter, foreign_key: :inviter_id, class_name: 'User'
  validates :inviter_id, :expires_at, presence: true

  def self.invite_for(country_code, phone_number)
    find_by(country_code: country_code, phone_number: phone_number, claimed: false)
  end

  def self.invite!(inviter, country_code, phone_number)
    if User.exists?(country_code: country_code, phone_number: phone_number)
      raise InviteError.new('user_already_exists')
    end

    existing_invite = find_by(country_code: country_code, phone_number: phone_number)
    if existing_invite && !existing_invite.expired?
      raise InviteError.new('invite_already_exists')
    end
    if existing_invite
      existing_invite.update!(expires_at: ServerSetting.invites_expire_after_hours.hours.from_now)
    else
      Invite.create!(
        inviter_id: inviter.id,
        expires_at: ServerSetting.invites_expire_after_hours.hours.from_now,
        country_code: country_code,
        phone_number: phone_number
      )
    end
    SmsProviders.instance.send_sms(
      sms_content: I18n.t(
        "invite_sms_message",
        server_name: ServerSetting.server_name,
        server_url: Rails.application.config.hostname,
        inviter: inviter.display_phone_number
      ),
      to: country_code + phone_number
    )
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
