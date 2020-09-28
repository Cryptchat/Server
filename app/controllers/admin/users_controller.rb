# frozen_string_literal: true

class Admin::UsersController < Admin::AdminController
  before_action :set_target_user, except: :index

  def index
    @users = User.all.order("created_at ASC")
  end

  def suspend
    if @user.admin?
      notice = t('.cant_suspend_admin')
    else
      @user.update!(suspended: true)
      notice = t('.suspend_successful', user: @user.display_phone_number)
    end
    redirect_to :admin_users, notice: notice
  end

  def unsuspend
    @user.update!(suspended: false)
    redirect_to :admin_users, notice: t('.unsuspend_successful', user: @user.display_phone_number)
  end

  def grant_admin
    if @user.suspended?
      notice = t('.cant_admin_suspended')
    else
      @user.update!(admin: true)
      notice = t('.grant_admin_successful', user: @user.display_phone_number)
    end
    redirect_to :admin_users, notice: notice
  end

  def revoke_admin
    @user.update!(admin: false)
    redirect_to :admin_users, notice: t('.revoke_admin_successful', user: @user.display_phone_number)
  end

  private

  def set_target_user
    @user = User.find(params[:user_id])
    if @user == current_admin
      redirect_to :admin_users, notice: t('.cant_change_yourself')
    end
  end
end
