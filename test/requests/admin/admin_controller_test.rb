# frozen_string_literal: true

require 'test_helper'

class Admin::AdminControllerTest < CryptchatIntegrationTest
  test 'denies access when non-admins attempt to access' do
    get '/admin'
    assert_equal(404, response.status)
    user = Fabricate(:user)
    sign_in(user)
    get '/admin'
    assert_equal(404, response.status)
  end

  test 'grants admins access' do
    user = Fabricate(:user, admin: true)
    sign_admin_in(user)
    get '/admin'
    assert_redirected_to :admin_users
    assert_equal(301, response.status)
  end
end
