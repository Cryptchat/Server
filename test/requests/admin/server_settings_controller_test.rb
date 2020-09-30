# frozen_string_literal: true

require 'test_helper'

class Admin::ServerSettingsControllerTest < CryptchatIntegrationTest
  setup do
    @admin = Fabricate(:user, admin: true)
    sign_admin_in(@admin)
  end

  test '#index lists all settings' do
    get '/admin/settings'
    assert_equal(200, response.status)
    assert_select('form', ServerSetting.defaults.size)
    assert_select('.overriden', 0)
    assert_includes(response.body, ServerSetting.server_name)
    ServerSetting.server_name = 'my test server'

    get '/admin/settings'
    assert_equal(200, response.status)
    assert_select('form', ServerSetting.defaults.size)
    assert_select('.overriden', 1)
    assert_includes(response.body, ServerSetting.server_name)
  end

  test '#update can update setting value' do
    put '/admin/settings/server_name', params: {
      perform: 'save',
      value: 'some new server name'
    }
    assert_equal(302, response.status)
    assert_equal('some new server name', ServerSetting.server_name)
  end

  test '#update can revert setting value to default' do
    put '/admin/settings/server_name', params: {
      perform: 'save',
      value: 'some new server name'
    }
    assert_equal(302, response.status)
    assert_equal('some new server name', ServerSetting.server_name)

    put '/admin/settings/server_name', params: {
      perform: 'revert'
    }
    assert_equal(302, response.status)
    assert_equal('Cryptchat Server', ServerSetting.server_name)
  end
end
