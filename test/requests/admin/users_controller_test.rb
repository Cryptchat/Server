# frozen_string_literal: true

require 'test_helper'

class Admin::UsersControllerTest < CryptchatIntegrationTest
  setup do
    @admin = Fabricate(:user, admin: true)
    sign_admin_in(@admin)
  end

  test '#index lists all users' do
    Fabricate(:user)
    Fabricate(:user, suspended: true)

    get '/admin/users'
    assert_equal(200, response.status)
    assert_select('.user-row', 3)
    assert_select('.user-avatar-and-info.suspended', 1)
  end

  test '#suspend can suspend user' do
    target = Fabricate(:user)
    put "/admin/users/#{target.id}/suspend"
    assert_redirected_to :admin_users
    assert(target.reload.suspended?)
  end

  test '#suspend cannot suspend admin' do
    target = Fabricate(:user, admin: true)
    put "/admin/users/#{target.id}/suspend"
    assert_redirected_to :admin_users
    refute(target.reload.suspended?)
  end

  test '#suspend cannot suspend self' do
    put "/admin/users/#{@admin.id}/suspend"
    assert_redirected_to :admin_users
    refute(@admin.reload.suspended?)
  end

  test '#unsuspend can unsuspend users' do
    target = Fabricate(:user, suspended: true)
    put "/admin/users/#{target.id}/unsuspend"
    assert_redirected_to :admin_users
    refute(target.reload.suspended?)
  end

  test '#grant_admin can grant admin rights to users' do
    target = Fabricate(:user)
    put "/admin/users/#{target.id}/grant-admin"
    assert_redirected_to :admin_users
    assert(target.reload.admin?)
  end

  test '#grant_admin cannot grant admin rights to suspended users' do
    target = Fabricate(:user, suspended: true)
    put "/admin/users/#{target.id}/grant-admin"
    assert_redirected_to :admin_users
    refute(target.reload.admin?)
  end

  test '#revoke_admin can remove admin rights from users' do
    target = Fabricate(:user, admin: true)
    put "/admin/users/#{target.id}/revoke-admin"
    assert_redirected_to :admin_users
    refute(target.reload.admin?)
  end

  test '#revoke_admin cannot remove admin rights from self' do
    put "/admin/users/#{@admin.id}/revoke-admin"
    assert_redirected_to :admin_users
    assert(@admin.reload.admin?)
  end
end
