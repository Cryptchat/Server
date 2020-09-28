# frozen_string_literal: true

class Admin::UsersController < Admin::AdminController
  def index
    @users = User.all.order("created_at ASC")
  end

  def update
    @user = User.find(params[:id])
    if @user == current_admin
      return redirect_to :admin_users, notice: t('.cant_change_yourself')
    end
    notice = nil
    key = nil
    if params.key?('suspend')
      if @user.admin?
        notice = t('.cant_suspend_admin')
      else
        @user.update!(suspended: true)
        key = 'suspend'
      end
    elsif params.key?('grant_admin')
      if @user.suspended?
        notice = t('.cant_admin_suspended')
      else
        @user.update!(admin: true)
        key = 'grant_admin'
      end
    elsif params.key?('unsuspend')
      @user.update!(suspended: false)
      key = 'unsuspend'
    elsif params.key?('revoke_admin')
      @user.update!(admin: false)
      key = 'revoke_admin'
    else
      notice = t('.unknown_action')
    end
    if notice.nil? && !key.nil?
      notice = t(".#{key}_successful", user: @user.display_phone_number)
    end
    redirect_to :admin_users, notice: notice
  end
end
