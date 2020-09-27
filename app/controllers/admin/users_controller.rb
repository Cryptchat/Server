# frozen_string_literal: true

class Admin::UsersController < Admin::AdminController
  def index
    @users = User.all.order("created_at ASC")
  end

  def update
    @user = User.find(params[:id])
    puts params
  end
end
