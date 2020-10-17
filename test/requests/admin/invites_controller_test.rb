# frozen_string_literal: true

require 'test_helper'

class Admin::InvitesControllerTest < CryptchatIntegrationTest
  setup do
    @admin = Fabricate(:user, admin: true)
    sign_admin_in(@admin)
  end

  test '#index has a form to invite users' do
    get '/admin/invites'
    assert_equal(200, response.status)
    assert_select('.invite-form input[type="tel"]', 1)
    assert_select('.invite-form select', 1)
  end

  test '#create requires country code and phone number' do
    post '/admin/invites'
    get response.headers['Location']
    assert_select('.flash-notice.error', I18n.t('admin.invites.create.empty_country_code_or_number'))

    post '/admin/invites', params: { country: 'SA' }
    get response.headers['Location']
    assert_select('.flash-notice.error', I18n.t('admin.invites.create.empty_country_code_or_number'))

    post '/admin/invites', params: { phone_number: '512345678' }
    get response.headers['Location']
    assert_select('.flash-notice.error', I18n.t('admin.invites.create.empty_country_code_or_number'))
  end

  test '#create validates country code' do
    post '/admin/invites', params: { country: 'SX', phone_number: '512345678' }
    get response.headers['Location']
    assert_select('.flash-notice.error', I18n.t('admin.invites.create.not_allowed_country'))
  end

  test '#create validates phone number' do
    post '/admin/invites', params: { country: 'SA', phone_number: '21 234 5678' }
    get response.headers['Location']
    assert_select('.flash-notice.error', I18n.t('admin.invites.create.invalid_number'))

    post '/admin/invites', params: { country: 'KW', phone_number: '51 234 5678' }
    get response.headers['Location']
    assert_select('.flash-notice.error', I18n.t('admin.invites.create.invalid_number'))

    post '/admin/invites', params: { country: 'SA', phone_number: '5A 234 5678' }
    get response.headers['Location']
    assert_select('.flash-notice.error', I18n.t('admin.invites.create.invalid_number'))

    stub_invite_sms(@admin, '+966', '512345678')
    post '/admin/invites', params: { country: 'SA', phone_number: '51 234 5678' }
    get response.headers['Location']
    assert_select('.flash-notice.error', 0)
    assert(Invite.find_by(country_code: '+966', phone_number: '512345678'))

    stub_invite_sms(@admin, '+962', '112341234')
    post '/admin/invites', params: { country: 'JO', phone_number: '1 1234 1234' }
    get response.headers['Location']
    assert_select('.flash-notice.error', 0)
    assert(Invite.find_by(country_code: '+962', phone_number: '112341234'))
  end

  test '#create does not allow inviting existing users' do
    Fabricate(:user, country_code: '+966', phone_number: '512345678')
    post '/admin/invites', params: { country: 'SA', phone_number: '51 234 5678' }
    get response.headers['Location']
    assert_select('.flash-notice.error', I18n.t('admin.invites.create.user_already_exists'))
    assert_equal(0, Invite.all.count)
  end

  test '#create does not allow reinviting unless old invite has expired' do
    invite = Fabricate(:invite, country_code: '+966', phone_number: '512345678', expires_at: 5.minutes.from_now)
    post '/admin/invites', params: { country: 'SA', phone_number: '51 234 5678' }
    get response.headers['Location']
    assert_select('.flash-notice.error', I18n.t('admin.invites.create.invite_already_exists'))
    assert_equal(1, Invite.all.count)
    assert_equal(5.minutes.from_now.to_i, invite.reload.expires_at.to_i)

    travel(10.minutes)
    post '/admin/invites', params: { country: 'SA', phone_number: '51 234 5678' }
    get response.headers['Location']
    assert_equal(1, Invite.all.count)
    assert_equal(24.hours.from_now.to_i, invite.reload.expires_at.to_i)
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
