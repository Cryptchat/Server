# frozen_string_literal: true
require 'test_helper'

class InviteTest < ActiveSupport::TestCase
  test '.invite! raises when invited number already registered' do
    user = Fabricate(:user, country_code: '+966', phone_number: '13313')
    exception = assert_raises(Invite::InviteError) do
      Invite.invite!(Fabricate(:user), user.country_code, user.phone_number)
    end
    assert_equal('user_already_exists', exception.message)
  end

  test '.invite! raises when there is already an unexpired invite' do
    invite = Fabricate(:invite, country_code: '+966', phone_number: '13313', expires_at: 5.minutes.from_now)
    exception = assert_raises(Invite::InviteError) do
      Invite.invite!(Fabricate(:user), invite.country_code, invite.phone_number)
    end
    assert_equal('invite_already_exists', exception.message)
  end

  test '.invite! works when there is an expired invite' do
    invite = Fabricate(:invite, country_code: '+966', phone_number: '13313', expires_at: 5.minutes.ago)
    inviter = Fabricate(:user)
    refute_equal(inviter.id, invite.inviter_id)
    stub_invite_sms(inviter, invite.country_code, invite.phone_number)
    Invite.invite!(inviter, invite.country_code, invite.phone_number)
    assert(ServerSetting.invites_expire_after_hours.hours.from_now.to_i == invite.reload.expires_at.to_i)
    assert_equal(inviter.id, invite.inviter_id)
  end

  test '.invite! works' do
    inviter = Fabricate(:user)
    country_code = '+966'
    phone_number = '8301212'
    stub_invite_sms(inviter, country_code, phone_number)
    assert_equal(0, Invite.all.count)
    Invite.invite!(inviter, country_code, phone_number)
    assert_equal(1, Invite.where(country_code: country_code, phone_number: phone_number).count)
  end

  private

  def stub_invite_sms(inviter, country_code, phone_number)
    stub_sms(
      country_code + phone_number,
      I18n.t(
        "invite_sms_message",
        server_name: ServerSetting.server_name,
        server_url: Rails.application.config.hostname,
        inviter: inviter.display_phone_number
      )
    )
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
